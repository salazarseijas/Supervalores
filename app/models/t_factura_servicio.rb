class TFacturaServicio < ApplicationRecord
  belongs_to :t_conf_fac_automatica
  belongs_to :t_tarifa_servicio
end