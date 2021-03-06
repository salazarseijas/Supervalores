# == Schema Information
#
# Table name: view_resolution_balance
#
#  t_cliente_id    :bigint
#  t_resolucion_id :bigint
#  resolucion      :string
#  pagos_recibidos :float
#  total_facturado :float
#

class ViewResolutionBalance < ApplicationRecord
  self.table_name = 'view_resolution_balance'
  
  protected

  # The report_state_popularities relation is a SQL view,
  # so there is no need to try to edit its records ever.
  # Doing otherwise, will result in an exception being thrown
  # by the database connection.
  def readonly?
    true
  end

end
