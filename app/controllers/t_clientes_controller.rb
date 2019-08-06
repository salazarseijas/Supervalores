class TClientesController < ApplicationController
  before_action :seleccionar_cliente, only: [:show, :edit, :update, :destroy]

  def index
    @usar_dataTables = true
    @registros = TCliente.all
  end

  def show
  end

  def new
    @registro = TCliente.new
  end

  def edit
  end

  def create
    @registro = TCliente.new(parametros_cliente)

    respond_to do |format|
      if @registro.save
        format.html { redirect_to @registro, notice: 'Cliente creado correctamente.' }
        format.json { render :show, status: :created, location: @registro }
      else
        format.html { render :new }
        format.json { render json: @registro.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @registro.update(parametros_cliente)
        format.html { redirect_to @registro, notice: 'Cliente actualizado correctamente.' }
        format.json { render :show, status: :ok, location: @registro }
      else
        format.html { render :edit }
        format.json { render json: @registro.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy 
    @registro.estatus = 0

    if @registro.save
      format.html { redirect_to t_clientes_url, notice: 'Cliente inhabilitado correctamente.' }
      format.json { head :no_content }
    else
      format.html { render :new }
      format.json { render json: @registro.errors, status: :unprocessable_entity }
    end
  end

  private
    def seleccionar_cliente
      @registro = TCliente.find(params[:id])
    end

    def parametros_cliente
      params.require(:t_cliente).permit(:codigo, :t_estatus_id, :cuenta_venta, :t_tipo_cliente_id, :t_tipo_persona_id, :user_id, :razon_social, :telefono, :email, :prospecto_at)
    end
end
