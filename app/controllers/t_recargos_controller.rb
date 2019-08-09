class TRecargosController < ApplicationController
  before_action :set_t_recargo, only: [:edit, :update, :show, :destroy]

  def new
    @t_recargo = TRecargo.new
  end

  def create
    @t_recargo = TRecargo.new(t_recargo_params)

    if @t_recargo.save
      # flash[:success] = "Recargo creada exitosamente."
      redirect_to t_recargos_path
    else
      # flash.now[:danger] = "No se pudo crear el recargo."
      render 'new'
    end
  end

  def edit
  end

  def update
    if @t_recargo.update(t_recargo_params)
      # flash[:success] = "Recargo actualizado exitosamente."
      redirect_to t_recargos_path
    else
      # flash.now[:danger] = "No se pudo modificar el recargo."
      render 'edit'
    end
  end

  def index
    @t_recargos = TRecargo.all
  end

  def show
  end

  def destroy
    @t_recargo.destroy

    # flash[:warning] = "Recargo eliminado."
    redirect_to t_recargos_path
  end

  private

    def t_recargo_params
      params.require(:t_recargo).permit(:descripcion, :tasa, :estatus, :factura_id)
    end

    def set_t_recargo
      @t_recargo = TRecargo.find(params[:id])
    end
end