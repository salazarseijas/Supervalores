class CreateInformeTramitesTarifasRegistradas < ActiveRecord::Migration[5.2]
  def self.up
    self.connection.execute %Q( CREATE OR REPLACE VIEW informe_tramites_tarifas_registradas AS
      SELECT 
        pp.id
        , pp.nombre
        , CONCAT(pp.id, ' - ', pp.nombre) AS codigo_nombre
        , pp.cantidad total_cantidad
        , pp.monto total_monto
        , pp.datos[1] anio
        , pp.datos[2] anio_cantidad
        , pp.datos[3] anio_monto
      FROM (
        SELECT 
          rw.id
          , rw.nombre
          , rw.cantidad
          , rw.monto
          , string_to_array(datos."value", '|') datos
        FROM (
          SELECT 
            dt.id
            , dt.nombre
            , sum(dt.cantidad) AS cantidad
            , sum(dt.monto) as monto
            , array_agg(concat_ws('|', dt.anio, dt.cantidad, dt.monto)) datos
          FROM (
            SELECT 
              ts.id
              , ts.nombre
              , date_part('year', f.created_at) anio
              , count(ts.id) AS cantidad
              , sum(f.total_factura) as monto
            FROM ((t_tarifa_servicios ts
              JOIN t_factura_detalles fd ON ((fd.t_tarifa_servicio_id = ts.id)))
              JOIN t_facturas f ON ((fd.t_factura_id = f.id)))
            GROUP BY 1,2,3
            ORDER BY 1,2,3 desc
          ) dt
          GROUP BY 1, 2
         ) rw
         , UNNEST (rw.datos) datos("value")
       ) pp;
    )
  end

  def self.down
    self.connection.execute "DROP VIEW IF EXISTS informe_tramites_tarifas_registradas;"
  end
end
