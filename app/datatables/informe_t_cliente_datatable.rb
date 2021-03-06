class InformeTClienteDatatable < ApplicationDatatable
  def view_columns
    @view_columns ||= {
      identificacion: { source: "InformeDeClientesView.identificacion" },
      razon_social: { source: "InformeDeClientesView.razon_social" },
      resolucion: { source: "InformeDeClientesView.resolucion" },
      fecha_notificacion: { source: "InformeDeClientesView.fecha_notificacion" },
      fecha_vencimiento: { source: "InformeDeClientesView.fecha_vencimiento" },
      recargo: { source: "InformeDeClientesView.recargo" },
      total_factura: { source: "InformeDeClientesView.total_factura" }
    }
  end

  def data
    records.map do |record|
      {
        identificacion: record.identificacion,
        razon_social: record.razon_social,
        resolucion: record.resolucion,
        fecha_notificacion: record.fecha_notificacion,
        fecha_vencimiento: record.fecha_vencimiento,
        recargo: record.recargo,
        total_factura: number_to_balboa(record.total_factura, false),
        DT_RowId: url_for({
          id: record.t_factura_id, controller: 't_facturas', action: 'preview', only_path: true
        })
      }
    end
  end

  def get_raw_records
    t_clientes =
      if !params[:day].blank?
        InformeDeClientesView.where('fecha_notificacion = ?', params[:day])
      elsif !params[:ztart].blank? && !params[:end].blank?
        InformeDeClientesView.where('fecha_notificacion BETWEEN ? AND ?', params[:ztart], params[:end])
      elsif !params[:month_year].blank?
        InformeDeClientesView.where('fecha_notificacion BETWEEN ? AND ?',
          params[:month_year], params[:month_year].to_date.at_end_of_month.strftime('%d/%m/%Y'))
      elsif !params[:bimonthly].blank?
        InformeDeClientesView.where('fecha_notificacion BETWEEN ? AND ?',
          params[:bimonthly], (params[:bimonthly].to_date + 1.month).at_end_of_month.strftime('%d/%m/%Y'))
      elsif !params[:quarterly].blank?
        InformeDeClientesView.where('fecha_notificacion BETWEEN ? AND ?',
          params[:quarterly], (params[:quarterly].to_date + 2.months).at_end_of_month.strftime('%d/%m/%Y'))
      elsif !params[:biannual].blank?
        InformeDeClientesView.where('fecha_notificacion BETWEEN ? AND ?',
          params[:biannual], (params[:biannual].to_date + 5.months).at_end_of_month.strftime('%d/%m/%Y'))
      elsif !params[:year].blank?
        InformeDeClientesView.where('fecha_notificacion BETWEEN ? AND ?',
          params[:year], params[:year].to_date.at_end_of_year.strftime('%d/%m/%Y'))
      else
        InformeDeClientesView.all
      end
    t_clientes.where(t_tipo_cliente_id: params[:t_tipo_cliente_id])
  end
end
