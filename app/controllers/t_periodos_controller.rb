class TPeriodosController < ApplicationController
  before_action :seleccionar_periodo, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    @usar_dataTables = true
    @attributes_to_display = [
      :descripcion, :tipo, :dia_tope, :mes_tope, :estatus
    ]

    respond_to do |format|
      format.html
      format.json { render json: ApplicationDatatable.new(
        params.merge({ attributes_to_display: @attributes_to_display }),
        view_context: view_context)
      }
    end
  end

  def show
  end

  def new
    @registro = TPeriodo.new
  end

  def edit
  end

  def create
    @registro = TPeriodo.new(t_periodo_params)
    @registro.rango_dias = TPeriodo.translate_period_type_to_days(@registro.tipo)
    
    respond_to do |format|
      if @registro.save
        format.html { redirect_to @registro, notice: 'Período creado correctamente.' }
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
      if @registro.update(t_periodo_params)
        format.html { redirect_to @registro, notice: 'Período actualizado correctamente.' }
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
        format.html { redirect_to t_tipo_clientes_url, notice: 'Período inhabilitado correctamente.' }
        format.json { head :no_content }
      else
        @notice = @registro.errors
        format.html { render :new }
        format.json { render json: @registro.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def seleccionar_periodo
      @registro = TPeriodo.find(params[:id])
    end

    def t_periodo_params
      params.require(:t_periodo).permit(:descripcion, :tipo, :dia_tope, :mes_tope, :estatus)
    end
end
