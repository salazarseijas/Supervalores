# == Schema Information
#
# Table name: t_tipo_clientes
#
#  id                     :bigint           not null, primary key
#  codigo                 :string           not null
#  descripcion            :string           not null
#  estatus                :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  t_tarifa_id            :bigint           not null
#  t_tipo_cliente_tipo_id :bigint           not null
#  t_periodo_id           :bigint
#

class TTipoCliente < ApplicationRecord
	belongs_to :t_tarifa
	belongs_to :t_periodo
	belongs_to :t_tipo_cliente_tipo
	
	has_many :t_clientes
  has_one :t_resolucion
	#has_and_belongs_to_many :t_tarifa

	validates :codigo, 
		presence: {
			message: "|El código no puede estar vacío."
		},
    format: { 
      message: "|El código solo puede tener Letras, Números y Guiones(-).",
      with: /([A-Za-z0-9\-]+)/ 
    },
    uniqueness: {
      message: "|Ya existe un tipo de cliente con este código, use otro por favor.",
    },
		:on => [:create, :update]

	validates :descripcion, 
		presence: {
			message: "|El descripción no puede estar vacío."
		},
		length: {
			message: "|La descripción debe tener minimo 2 caracteres.",
			minimum: 2
		},
		:on => [:create, :update]
	
	validates :estatus, 
		presence: {
			message: "|El estatus no puede estar vacío."
		},
    format: { 
      message: "|El código solo puede tener Letras, Números y Guiones(-).",
      with: /([0|1])/ 
    },
		:on => [:create, :update]

	validates :t_tarifa_id, 
		presence: {
			message: "|Debe indicar la tarifa asociada al tipo de cliente."
		},
		:on => [:create, :update]

  before_save :before_save_record

  def before_save_record
    codigo.upcase!
  end
end
