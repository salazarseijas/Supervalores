class TTipoClientesController < ApplicationController
  before_action :seleccionar_tipo_cliente, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:clients_index]

  def informe
    @usar_dataTables = true
    @do_not_use_plain_select2 = true
    @attributes_to_display = [
      :tipo_cliente, :anio_pago, :pago_enero, :pago_febrero, :pago_marzo,
      :pago_abril, :pago_mayo, :pago_junio, :pago_julio, :pago_agosto,
      :pago_septiembre, :pago_octubre, :pago_noviembre, :pago_diciembre, :total
    ]

    respond_to do |format|
      format.html
      format.json { render json: InformeTTipoClienteDatatable.new(
        params.merge({
          attributes_to_display: @attributes_to_display
        }),
        view_context: view_context)
      }
    end
  end

  def clients_index
    @t_tipo_cliente = TTipoCliente.find(params[:id])
    @usar_dataTables = true
    @do_not_use_plain_select2 = true
    @attributes_to_display = [
      :identificacion, :razon_social, :resolucion, :fecha_notificacion,
      :fecha_vencimiento, :recargo, :total_factura
    ]

    respond_to do |format|
      format.html
      format.json { render json: InformeTClienteDatatable.new(
        params.merge({
          attributes_to_display: @attributes_to_display,
          t_tipo_cliente_id: @t_tipo_cliente.id
        }),
        view_context: view_context)
      }
    end
  end

  def index
    @usar_dataTables = true
    @attributes_to_display = [
      :codigo, :descripcion, :t_tipo_cliente_tipo,
      :t_periodo, :t_tarifa, :estatus
    ]

    respond_to do |format|
      format.html
      format.json { render json: TTipoClienteDatatable.new(
        params.merge({
          attributes_to_display: @attributes_to_display
        }),
        view_context: view_context)
      }
    end
  end

  def show
  end

  def new
    @registro = TTipoCliente.new
  end

  def edit
  end

  def create
    @registro = TTipoCliente.new(t_tipo_cliente_params)

    respond_to do |format|
      if @registro.save
        format.html { redirect_to @registro, notice: 'Tipo de cliente creado correctamente.' }
        format.json { render :show, status: :created, location: @registro }
      else
        @notice = @registro.errors
        format.html { render :new }
        format.json { render json: @registro.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @registro.update(t_tipo_cliente_params)
        format.html { redirect_to @registro, notice: 'Tipo de cliente actualizado correctamente.' }
        format.json { render :show, status: :ok, location: @registro }
      else
        @notice = @registro.errors
        format.html { render :edit }
        format.json { render json: @registro.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @registro.estatus = 0
    respond_to do |format|
      if @registro.save
        format.html { redirect_to t_tipo_clientes_url, notice: 'Tipo de cliente inhabilitado correctamente.' }
        format.json { head :no_content }
      else
        @notice = @registro.errors
        format.html { render :new }
        format.json { render json: @registro.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def seleccionar_tipo_cliente
      @registro = TTipoCliente.find(params[:id])
    end

    def t_tipo_cliente_params
      params.require(:t_tipo_cliente).permit(:codigo, :descripcion, :t_tipo_cliente_tipo_id, :t_periodo_id, :estatus, :t_tarifa_id)
    end
end
