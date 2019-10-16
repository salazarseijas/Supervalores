class TFactura < ApplicationRecord
	#belongs_to :t_cliente
  belongs_to :t_resolucion
  belongs_to :t_periodo, optional: true
  belongs_to :t_estatus
  # belongs_to :t_estatus_fac
  belongs_to :t_leyenda, optional: true
  belongs_to :user

  has_many :t_factura_detalles, dependent: :destroy
  accepts_nested_attributes_for :t_factura_detalles, allow_destroy: true
  has_many :t_recibos, dependent: :destroy
  has_many :t_email_masivos, dependent: :destroy
  has_many :t_nota_creditos, dependent: :destroy
  has_many :t_estado_cuentums, dependent: :destroy
  has_many :t_clientes, through: :t_estado_cuentum
  has_many :t_recargo_facturas, dependent: :destroy
  has_many :t_recargos, through: :t_recargo_facturas

  validates :fecha_notificacion, presence: {
    message: "|La fecha de notificación no puede estar vacía"
  }
  validates :fecha_vencimiento, presence: {
    message: "|La fecha de vencimiento no puede estar vacía"
  }
  validates :t_resolucion, presence: {
    message: "|La resolución debe existir"
  }

  def calculate_pending_payment(before_save = false)
    if before_save
      sum = 0
      self.t_recibos.each { |t_recibo| sum += t_recibo.pago_recibido }
      (self.calculate_services_total_price(before_save) + self.recargo || 0) - sum
    else
      (self.calculate_services_total_price(before_save) + self.recargo || 0) - self.t_recibos.sum(:pago_recibido)
    end
  end

  def calculate_services_total_price(before_save = false)
    if before_save
      sum = 0
      self.t_factura_detalles.each { |t_factura_detalle| sum += t_factura_detalle.precio_unitario }
      sum
    else
      self.t_factura_detalles.sum(:precio_unitario)
    end
  end

  def calculate_total_surcharge_rate(before_save = false)
    if before_save
      sum = 0
      self.t_recargos.each { |t_recargo| sum += t_recargo.tasa }
      sum
    else
      self.t_recargos.sum(:tasa)
    end
  end

  def calculate_total_surcharge(before_save = false)
    if before_save
      calculate_total_surcharge_rate(true) * calculate_services_total_price(true)
    else
      calculate_total_surcharge_rate * calculate_services_total_price
    end
  end

  def calculate_total(before_save = false)
    if before_save
      calculate_services_total_price(true) + calculate_total_surcharge(true)
    else
      calculate_services_total_price + calculate_total_surcharge
    end
  end

  def self.count_invoices_by_month(month_number)
    TFactura.where('extract(month  from created_at) = ?', month_number).count
  end

  def self.count_invoices_by_months(number_of_months)
    older_month = (Date.today - number_of_months.months).month
    invoices_list = []

    (older_month..Date.today.month).each do |month_number|
      invoices_list << TFactura.count_invoices_by_month(month_number)
    end

    invoices_list
  end

  def get_next_surcharge_date(due_date)
    self.t_recargos.each_with_index do |t_recargo, i|
      next_surcharge_date = (due_date + 1.day) if i == 0
      next_surcharge_date = (due_date + t_recargo.t_periodo.rango_dias.days) if next_surcharge_date >
                            (due_date + t_recargo.t_periodo.rango_dias.days)
    end
    next_surcharge_date
  end

  def generate_surcharge
    t_recibos = self.t_recibos

    if t_recibos.any?
      t_recibo = t_recibos.last
      surcharge_to_apply = t_recibo.servicios_x_pagar * (2.0 / 100.0)
      total_surcharge = t_recibo.recargo_x_pagar + surcharge_to_apply

      if total_surcharge < t_recibo.servicios_x_pagar
        t_recibo.recargo_x_pagar = total_surcharge.truncate(2)
      else
        t_recibo.recargo_x_pagar = t_recibo.servicios_x_pagar
      end

      t_recibo.save!
    else
      services_total_price = self.calculate_services_total_price
      surcharge_to_apply = services_total_price * (2.0 / 100.0)
      total_surcharge = self.recargo + surcharge_to_apply

      if total_surcharge < services_total_price
        # t_recargo = TRecargo.where(
        #   tasa: 0.02,
        #   t_periodo: TPeriodo.where(rango_dias: 30)
        # ).first_or_create!
        self.recargo = total_surcharge.truncate(2)
      else
        self.recargo = services_total_price
      end

      self.save!
      puts 'Factura actualizada con el nuevo recargo!'
      puts "self.recargo: #{self.recargo}"
      puts "total_surcharge: #{total_surcharge}"
    end
  end

  def apply_2_percent_monthly_surcharge
    scheduler = Rufus::Scheduler.singleton

    if self.t_estatus.descripcion.downcase == 'disponible'
      scheduler.schedule_every '1month' do |job|
      # scheduler.schedule_every '20s' do |job|
        t_factura = TFactura.find(self.id)
        if t_factura.t_estatus.descripcion.downcase == 'disponible'
          t_recibos = t_factura.t_recibos
          unless t_recibos.any? && t_recibos.last.pago_pendiente <= 0
            generate_surcharge
          else
            puts "Terminating 2\% surcharge jobs!"
            job.unschedule if job.scheduled?
            job.kill if job.running?
          end 
        else
          puts "Terminating 2\% surcharge jobs!"
          job.unschedule if job.scheduled?
          job.kill if job.running?
        end
      end
    end
  end
end
