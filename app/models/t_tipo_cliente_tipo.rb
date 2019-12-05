# == Schema Information
#
# Table name: t_tipo_cliente_tipos
#
#  id          :bigint           not null, primary key
#  descripcion :string
#  estatus     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class TTipoClienteTipo < ApplicationRecord
  
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
    :on => [:create, :update]
    
end
