class TTipoPersonasController < ApplicationController
  before_action :seleccionar_tipo_persona, only: [:show, :edit, :update, :destroy]

  #load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
		redirect_to dashboard_access_denied_path, :alert => exception.message
	end

  def index
    @usar_dataTables = true
    @registros = TTipoPersona.all
  end

  def show
  end

  def new
    @registro = TTipoPersona.new
  end

  def edit
  end

  def create
    @registro = TTipoPersona.new(parametros_tipo_persona)
    authorize! :create, @registro

    respond_to do |format|
      if @registro.save
        format.html { redirect_to @registro, notice: 'Tipo de persona creado correctamente.' }
        format.json { render :show, status: :created, location: @registro }
      else
        @notice = @registro.errors
        format.html { render :new }
        format.json { render json: @registro.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :update, @registro

    respond_to do |format|
      if @registro.update(parametros_tipo_persona)
        format.html { redirect_to @registro, notice: 'Tipo de persona actualizado correctamente.' }
        format.json { render :show, status: :ok, location: @registro }
      else
        @notice = @registro.errors
        format.html { render :edit }
        format.json { render json: @registro.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, @registro

    @registro.estatus = 0
    respond_to do |format|
      if @registro.save
        format.html { redirect_to t_tipo_personas_url, notice: 'Tipo de persona inhabilitado correctamente.' }
        format.json { head :no_content }
      else
        @notice = @registro.errors
        format.html { render :new }
        format.json { render json: @registro.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def seleccionar_tipo_persona
      @registro = TTipoPersona.find(params[:id])
    end

    def parametros_tipo_persona
      params.require(:t_tipo_persona).permit(:descripcion, :estatus)
    end
end
