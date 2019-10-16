class TRecibo < ApplicationRecord
	belongs_to :t_factura
  belongs_to :t_cliente
  belongs_to :t_periodo, optional: true
  belongs_to :t_metodo_pago
  belongs_to :user

  #has_many :t_recibo_detalle
  has_many :t_cajas, dependent: :destroy
  has_many :t_nota_creditos, dependent: :destroy

  has_many :t_estado_cuenta, dependent: :destroy
  has_many :t_clientes, through: :t_estado_cuentum

  validates :pago_recibido, numericality: {
    message: "|El monto pagado debe ser un número válido"
  }
  validates :num_cheque, presence: {
    message: "|El número de cheque no debe estar en blanco",
    if: :is_check
  }
  validate :received_payment_cannot_be_less_than_minimum_allowed
  validate :received_payment_cannot_be_more_than_maximum_allowed

  def received_payment_cannot_be_less_than_minimum_allowed
    t_metodo_pago = TMetodoPago.find(t_metodo_pago_id)
    if pago_recibido && t_metodo_pago.minimo && pago_recibido < t_metodo_pago.minimo
      errors.add(:pago_recibido, "|El monto pagado no puede ser menor que el mínimo permitido por el método de pago seleccionado (el mínimo es #{t_metodo_pago.minimo})")
    end
  end

  def received_payment_cannot_be_more_than_maximum_allowed
    t_metodo_pago = TMetodoPago.find(t_metodo_pago_id)
    if pago_recibido && t_metodo_pago.maximo && pago_recibido > t_metodo_pago.maximo
      errors.add(:pago_recibido, "|El monto pagado no puede ser mayor que el máximo permitido por el método de pago seleccionado (el máximo es #{t_metodo_pago.maximo})")
    end
  end

  def is_check
    self.t_metodo_pago == TMetodoPago.find_by(forma_pago: 'Cheque') || TMetodoPago.find_by(forma_pago: 'cheque')
  end

  def get_services_total(t_factura, has_no_receipts)
    has_no_receipts ? t_factura.calculate_services_total_price : t_factura.t_recibos.last.servicios_x_pagar
  end

  def get_total_surcharge(t_factura, has_no_receipts)
    has_no_receipts ? t_factura.recargo : t_factura.t_recibos.last.recargo_x_pagar
  end

  def set_surcharge_and_services_total(received_payment, t_factura, has_no_receipts)
    surcharge_remaining = (get_total_surcharge(t_factura, has_no_receipts) || 0) - (received_payment || 0)
    services_total = get_services_total(t_factura, has_no_receipts)

    if surcharge_remaining     > 0
      self.recargo_x_pagar     = surcharge_remaining.truncate(2)
      self.servicios_x_pagar   = t_factura.calculate_services_total_price.truncate(2)
      self.pago_pendiente      = (self.recargo_x_pagar + self.servicios_x_pagar).truncate(2)
      self.monto_acreditado    = 0
    else
      self.recargo_x_pagar     = 0
      if (services_remaining   = services_total + surcharge_remaining) > 0
        self.servicios_x_pagar = services_remaining.truncate(2)
        self.pago_pendiente    = services_remaining.truncate(2)
        self.monto_acreditado  = 0
      else
        self.servicios_x_pagar = 0
        self.pago_pendiente    = 0
        self.monto_acreditado  = (-services_remaining).truncate(2)
      end
    end
  end

  def calculate_default_attributes(t_factura, t_cliente, current_user)
    self.fecha_pago = Date.today
    self.t_factura = t_factura
    self.t_cliente = t_cliente
    self.estatus = 1
    self.user = current_user
  end

  def self.count_paid_receipts_by_month(month_number)
    TRecibo.where(
      'extract(month from created_at) = ?
      AND pago_pendiente <= ?',
      month_number,
      0
    ).count
  end

  def self.count_paid_receipts_by_months(number_of_months)
    older_month = (Date.today - number_of_months.months).month
    paid_receipts_list = []

    (older_month..Date.today.month).each do |month_number|
      paid_receipts_list << TRecibo.count_paid_receipts_by_month(month_number)
    end

    paid_receipts_list
  end
end
