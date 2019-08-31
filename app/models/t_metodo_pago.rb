class TMetodoPago < ApplicationRecord
	has_many :t_recibos, dependent: :destroy

	validates :forma_pago, presence: { message: "|La forma de pago no debe estar vacía" }
  validates :descripcion, presence: { message: "|La descripción no debe estar vacía" }
  validates :minimo, numericality: {
    message: "|El monto mínimo debe ser un número válido"
  }
  validates :maximo, numericality: {
    message: "|El monto máximo debe ser un número válido"
  }

	validate :validar_minimo, on: [:create, :update ]
	validate :validar_montos, on: [:create, :update ]

	def validar_minimo
	  if minimo != nil && minimo < 0
	    errors.add(:minimo, "El monto mínimo especificado no debe ser negativo ")
	  end
	end

	def validar_maximo
	  if minimo != nil && maximo < 0
	    errors.add(:minimo, "El monto máximo especificado no debe ser negativo")
	  end
	end

	def validar_montos
		if minimo != nil && maximo != nil && minimo > maximo
	    errors.add(:minimo, "El  monto mínimo especificado no debe ser mayor al monto máximo")
	  end
	end

end
