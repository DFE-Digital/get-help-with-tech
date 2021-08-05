class AssetsController < ApplicationController
  before_action :set_asset, only: [:show]

  # GET /assets
  def index
    setting = if current_user.is_responsible_body_user?
                current_user.responsible_body
              elsif current_user.is_school_user?
                current_user.schools.first
              end

    @assets = Asset.owned_by(setting)
  end

  # GET /assets/1
  def show; end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_asset
    @asset = Asset.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def asset_params
    params.require(:asset).permit(:tag, :serial_number, :model, :department, :department_id, :department_sold_to_id, :location, :location_id, :location_cc_ship_to_account, :encrypted_bios_password, :encrypted_admin_password, :encrypted_hardware_hash, :first_viewed_at)
  end
end
