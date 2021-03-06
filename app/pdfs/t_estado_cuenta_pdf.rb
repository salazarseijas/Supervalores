class TEstadoCuentaPdf < PdfHelper
#Cambiar nombre despues

  require 'prawn/measurement_extensions'
  require 'prawn/table'
  extend Forwardable
  def_delegator :@view, :number_to_currency

  # Constants
  GREEN      = '00B700'
  DARK_GREEN = '00B800'

  # Constructor
  # def initialize(t_factura, t_recibo, view)
  def initialize(t_cliente, t_resolucion ,nombre_recaudador)
    super()
    # @t_recibo     = t_recibo
    # @t_factura    = t_factura
    # @t_resolucion = @t_factura.t_resolucion
    @t_cliente    = t_cliente
    @t_resolucion = t_resolucion
    @t_empresa    = @t_cliente.persona.try(:rif)            ? @t_cliente.persona : nil
    @t_persona    = @t_cliente.persona.try(:cedula)         ? @t_cliente.persona : nil
    @t_otro       = @t_cliente.persona.try(:identificacion) ? @t_cliente.persona : nil
    ##################################################################################
    @nombre_recaudador = nombre_recaudador
    # 1 = Natural
    # 2 = Juridico
    @tipo_de_entidad = @t_cliente.persona_type.upcase == "TPERSONA" ? 1 : 2
    # @view = view
    @meses = [1 => "Enero", 2 => "Febrero", 3 => "Marzo", 4 => "Abril", 5 => "Mayo", 6 => "Junio", 7 => "Julio", 8 => "Agosto", 9 => "Septiembre", 10 => "Octubre", 11 => "Noviembre", 12 => "Diciembre"]
    font_size 10
    document_content
  end

  def document_content
    # stroke_axis(step_length: 50)
    page_one
    # pad_top(20) { stroke_horizontal_rule } # 0, bounds.width || 540, at: cursor }
    # move_down(5)
    # pad_top(5) { client }
    # stroke_horizontal_rule
    # invoice_detail
  end

  def logo
    image "#{Rails.root}/app/assets/images/logoSMV.png" , fit: [130,130]
  end

  def header
    fill_color '6D5F83'
    text_box "<b>REPÚBLICA DE PANAMÁ</b>
    <b>SUPERINTENDENCIA DEL MERCADO DE VALORES</b>
    <b>DEPARTAMENTO DE TESORERÍA</b>
    <b>FACTURA</b>", inline_format: true, at: [10,700], align: :center

    text_box "<b>Fecha de impresión: #{Time.now.strftime('%d/%m/%Y %I:%M:%S %p')}</b>", inline_format: true, at: [300,600], align: :right

    text_box "<b>Original Cliente</b>", inline_format: true, at: [480,740]
  end

  def client
    fill_color '000000'
    column_box([0, cursor], columns: 3, width: bounds.width, height: 30) do
      text "Cliente: \# #{@t_cliente.id}"
      text "Nombre: #{@t_persona.try(:nombre) || @t_empresa.try(:razon_social) || @t_otro.try(:razon_social)}"
      text "\n"

      text "Referencia:"
      text "Resolución: #{@t_resolucion.resolucion}"
      text "CIP / RUC: #{@t_persona.try(:cedula) || @t_empresa.try(:rif) || @t_otro.try(:identificacion)}"

      # text "Recibo: \# #{@t_recibo.id}"
      # text "Estado: #{(@t_recibo.pago_pendiente <= 0) ? 'Pagado' : 'Sin Pagar'}"
      text "Fecha: #{@t_factura.created_at.strftime('%d/%m/%Y %I:%M:%S %p')}"
    end
  end

  def invoice_detail
    data = [["Cantidad", "Ítem", "Descripción", "Precio", "Importe", "Saldo"]]

    table(data, cell_style: {borders: [:top, :bottom]}, width: bounds.width)
  end

  def example
    text_box "This is a text box, you can control where it will flow by " +
    "specifying the :height and :width options",
    :at =>[100, 250],
    :height => 100,
    :width => 100

    text_box "Another text box with no :width option passed, so it will " +
    "flow to a new line whenever it reaches the right margin. ",
    :at =>[200, 100]
  end

  def page_one
    logo
    fill_color '1A135C'
    text_box "<b>Fecha de impresión: #{Time.now.strftime('%d/%m/%Y %I:%M:%S %p')}</b>", inline_format: true, at: [330,750]

    text_box "<b>REPÚBLICA DE PANAMÁ</b>
    <b>SUPERINTENDENCIA DEL MERCADO DE VALORES</b>
    <b>DEPARTAMENTO DE TESORERÍA</b>", inline_format: true, at: [10,700], :align => :center

    text_box "<b>CERTIFICADO DE PAZ Y SALVO</b>", inline_format: true, at: [10,663], :align => :center

    stroke do
      move_down 40
      horizontal_rule
    end

    move_down 10

    text "<b>Certifica que:</b>", inline_format: true
  
    move_down 15
    if @tipo_de_entidad == 1
      nombre = @t_cliente.persona.nombre
      cip_ruc = @t_cliente.persona.cedula
    else
      nombre = @t_cliente.persona.razon_social
      cip_ruc = @t_cliente.persona.rif
    end
    paz_y_salvo = true
    
    @t_resolucion.t_facturas.each do |factura|
      saldo = (factura.t_recibos.sum(:pago_recibido) - factura.total_factura)
      if saldo >= 0
        paz_y_salvo = true
      else
        paz_y_salvo = false
      end
      break if paz_y_salvo == false
    end

    # debugger
    text "Nuestro cliente <b>#{nombre}</b> con C.I.P/R.U.C <b>#{cip_ruc}</b> y número de resolución <b>#{@t_resolucion.resolucion}</b>, #{paz_y_salvo ? "" : "no "}se mantiene paz y salvo hasta la fecha, con respecto a las cuentas que mantiene en la <b>Superintendencia del Mercado de Valores de la República de Panamá.</b>", inline_format: true

    move_down 15
    text "Dado a los #{DateTime.now.strftime('%d')} dia(s) del mes de #{@meses.first[DateTime.now.strftime('%m').to_i]} de #{DateTime.now.strftime('%Y')}."

    move_down 15

    fill_color '000000'

    text "<b>Recaudador(a):</b> <u>#{@nombre_recaudador}</u>", inline_format: true
    move_down 10
    text "<b>IMPORTANTE:</b> No es legalmente válido sin los sellos de caja", inline_format: true

    stroke do
      move_down 20
      horizontal_rule
    end
    # bounding_box([0, cursor], :width => 165, :height => 100) do
    #   # stroke_bounds
      
    #   text_box "<b>Dirección:</b>
    #   #{@t_empresa.try(:direccion_empresa) || @t_persona.try(:direccion)}
    #   <b>Apartado Postal:</b> ""
    #   <b>Teléfono:</b> #{@t_empresa.try(:telefono) || @t_persona.try(:telefono) || @t_otro.try(:telefono)}
    #   <b>Email:</b> #{@t_empresa.try(:email) || @t_persona.try(:email) || @t_otro.try(:email)}", inline_format: true, at: [5, cursor], :align => :justify
    # end

    # bounding_box([185, 644], :width => 165, :height => 100) do
    #   # stroke_bounds
    #   text_box "<b>Para Cliente:</b> #{@t_empresa.try(:razon_social) || @t_persona.try(:full_name) || @t_otro.try(:razon_social)}
    #   <b>Resolución:</b> #{@t_resolucion ? @t_resolucion.resolucion : 'Sin Resolución'}
    #   <b>CIP/RUC:</b> #{@t_empresa.try(:rif) || @t_persona.try(:cedula) || @t_otro.try(:identificacion)}
    #   <b>Teléfono:</b> #{@t_empresa.try(:telefono) || @t_persona.try(:telefono) || @t_otro.try(:telefono)}
    #   <b>Email:</b> #{@t_empresa.try(:email) || @t_persona.try(:email) || @t_otro.try(:email)}
    #   ", inline_format: true, at: [5, cursor], :align => :justify
    # end

    # bounding_box([370, 644], :width => 165, :height => 100) do
    #   # stroke_bounds
    #   text_box "<b>Factura:</b> #{@t_factura.id}
    #   <b>Estado:</b> #{@t_factura.t_estatus.descripcion}
    #   <b>Importe debido:</b> #{@t_factura.created_at.strftime('%d/%m/%Y %I:%M:%S %p')}
    #   <b>Fecha de vencimiento:</b> #{@t_factura.fecha_vencimiento.strftime('%d/%m/%Y')}
    #   ", inline_format: true, at: [5, cursor], :align => :justify
    # end

    # big_table_for_5_with_widths_and_alignment(
    #   bold("Cantidad"), 
    #   bold("Ítem"), 
    #   bold("Descripción"), 
    #   bold("Precio"), 
    #   bold("Importe"), 
    #   45, 150, 200, 80, :center)

    # @t_factura.t_factura_detalles.each do |fd|
    #   big_table_for_5_with_widths_and_alignment(
    #     "#{fd.cantidad}", 
    #     "#{fd.t_tarifa_servicio.nombre}", 
    #     "#{fd.cuenta_desc}", 
    #     "#{fd.precio_unitario}", 
    #     "#{fd.precio_unitario * fd.cantidad}", 
    #     45, 150, 200, 80, :center)
    # end

    # @t_factura.t_recargos.each do |r|
    #   big_table_for_5_with_widths_and_alignment(
    #     "", 
    #     "Recargo", 
    #     "#{r.descripcion}", 
    #     "#{r.tasa * @t_factura.calculate_services_total_price}", 
    #     "", 
    #     45, 150, 200, 80, :center)
    # end    
    # #######
    # #Loop here plz
    # #######

    # move_down 30

    # bounding_box([0, cursor], :width => 370, :height => 130) do
    #     # stroke_bounds
    #     text_box "Mediante la ley 67 de 1 de septiembre de 2011 publicada en la Gaceta Oficial No. 26863-A de 2 de septiembre de 2011, se crea la Superintendencia del Mercado de Valores como un organismo autónomo del Estado, con personería jurídica, patrimonio propio e independencia administrativa, presupuestaria y financiera, con competencia privativa para regular y supervisar a los emisores, sociedades de inversiones, intermediarios y demás participantes del mercados de valores.", inline_format: true, at: [5, cursor], :align => :justify
    # end

    # move_up 130

    # fill_color '000000'

    # data = [[bold("Total:"), bold("#{@t_factura.total_factura}")]]
    # table(data, :column_widths => [80, 80],
    #   :cell_style => {:inline_format => true, :border_width => 0.1, :align => :center,:height => 20}, width: 160, :position => :right )

    # fill_color '1A135C'

    # text_box "<b>2019 - 20 Años propiciando seguridad, confianza y transparencia</b>", inline_format: true, at: [170,10]
  end
end