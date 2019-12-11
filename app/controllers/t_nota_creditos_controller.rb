class TNotaCreditosController < ApplicationController
  before_action :set_t_nota_credito, only: [:show, :edit, :update, :destroy]

  # GET /t_nota_creditos
  # GET /t_nota_creditos.json
  def index
    @t_nota_creditos = TNotaCredito.all
  end

  # GET /t_nota_creditos/1
  # GET /t_nota_creditos/1.json
  def show
  end

  # GET /t_nota_creditos/new
  def new
    @t_nota_credito = TNotaCredito.new
  end

  # GET /t_nota_creditos/1/edit
  def edit
  end

  # POST /t_nota_creditos
  # POST /t_nota_creditos.json
  def create
    @t_nota_credito = TNotaCredito.new(t_nota_credito_params)

    respond_to do |format|
      if @t_nota_credito.save
        format.html { redirect_to @t_nota_credito, notice: 'T nota credito was successfully created.' }
        format.json { render :show, status: :created, location: @t_nota_credito }
      else
        format.html { render :new }
        format.json { render json: @t_nota_credito.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /t_nota_creditos/1
  # PATCH/PUT /t_nota_creditos/1.json
  def update
    respond_to do |format|
      if @t_nota_credito.update(t_nota_credito_params)
        format.html { redirect_to @t_nota_credito, notice: 'T nota credito was successfully updated.' }
        format.json { render :show, status: :ok, location: @t_nota_credito }
      else
        format.html { render :edit }
        format.json { render json: @t_nota_credito.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /t_nota_creditos/1
  # DELETE /t_nota_creditos/1.json
  def destroy
    @t_nota_credito.destroy
    respond_to do |format|
      format.html { redirect_to t_nota_creditos_url, notice: 'T nota credito was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_t_nota_credito
      @t_nota_credito = TNotaCredito.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def t_nota_credito_params
      params.require(:t_nota_credito).permit(:t_cliente_id, :t_recibo_id, :monto, :usada, :factura_redimida, :descripcion)
    end
end
