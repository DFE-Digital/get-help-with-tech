class AssetsController < ApplicationController
  before_action :require_sign_in!
  before_action :set_asset, only: :show

  # GET /assets
  def index
    @title = 'Assets'

    setting = if current_user.is_responsible_body_user?
                current_user.responsible_body
              elsif current_user.is_school_user?
                current_user.school
              end

    @assets = Asset.owned_by(setting)
  end

  # POST /assets/search
  # renders the index template
  def search
    @title = 'Search results'

    @current_serial_number = params[:serial_number]
    @assets = Asset.search_by_serial_number(@current_serial_number)

    render :index
  end

  # GET /assets/1
  def show
    if user_role_counts_as_view? && !@asset.viewed?
      @asset.update!(first_viewed_at: Time.zone.now)
    end
  end

private

  def user_role_counts_as_view?
    !current_user.is_support?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_asset
    @asset = Asset.find(params[:id])
  end
end
