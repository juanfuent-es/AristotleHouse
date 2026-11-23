
class Admin::ClientsController < ApplicationController

  before_action :authenticate_admin!
  before_action :set_client, only: %i[ show edit update destroy ]

  layout "admin"

  # GET /clients
  def index
    @clients = Client.all
  end

  # GET /clients/1
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to admin_clients_url, notice: "Client ha sido creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clients/1
  def update
    if @client.update(client_params)
      redirect_to admin_clients_url, notice: "Client ha sido actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /clients/1
  def destroy
    @client.destroy
    redirect_to admin_clients_url, notice: "Client ha sido eliminado."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.require(:client).permit(:name, :description, :url, :email, :logo, :country_id, :address)
    end
end
