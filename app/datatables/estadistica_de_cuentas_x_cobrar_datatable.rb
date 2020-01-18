class EstadisticaDeCuentasXCobrarDatatable < ApplicationDatatable
  def view_columns
    @view_columns ||= {
      codigo: { source: "EstadisticaDeCuentasXCobrarView.id" },
      nombre: { source: "EstadisticaDeCuentasXCobrarView.nombre" },
      total: { source: "EstadisticaDeCuentasXCobrarView.total_cantidad", searchable: false },
      anio: { source: "EstadisticaDeCuentasXCobrarView.anio" },
      anio_total: { source: "EstadisticaDeCuentasXCobrarView.anio_cantidad", searchable: false }
    }
  end

  def data
    records.map do |record|
      {
        codigo: record.id,
        nombre: record.nombre,
        total: (record.total_cantidad * record.total_monto*100).round / 100.0,        
        anio: record.anio,
        anio_total: (record.anio_cantidad.to_f * record.anio_monto.to_f*100).round / 100.0,
        DT_RowId: url_for({
          id: record.id, controller: 't_tarifa_servicios', action: 'show', only_path: true
        })
      }
    end
  end

  def get_raw_records
    tramites =
      if params[:ztart] && params[:ztart] != '' && params[:end] && params[:end] != ''
        EstadisticaDeCuentasXCobrarView.where('anio BETWEEN ? AND ?', params[:ztart], params[:end])
      elsif params[:year] && params[:year] != ''
        EstadisticaDeCuentasXCobrarView.where('anio = ?', params[:year])
      else
        EstadisticaDeCuentasXCobrarView.all
      end

    return tramites
  end
end
