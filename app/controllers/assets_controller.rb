class AssetsController < ApplicationController
  before_action :require_sign_in!
  before_action :set_asset, only: :show

  # GET /assets
  def index
    @title = 'Assets'

    user = impersonated_or_current_user

    setting = if user.is_responsible_body_user?
                user.responsible_body
              elsif user.is_school_user?
                user.school
              end

    @assets = policy_scope(Asset).owned_by(setting)

    respond_to do |format|
      format.html
      format.csv do
        Asset.transaction do
          send_data current_user.is_support? ? @assets.to_support_csv : @assets.to_non_support_csv
          @assets.each { |asset| set_first_viewed_at_if_should_update_first_viewed_at(asset) }
        end
      end
    end
  end

  # POST /assets/search
  # renders the index template
  def search
    @title = 'Search results'

    @current_serial_number = params[:serial_number]
    @assets = policy_scope(Asset).search_by_serial_number(@current_serial_number)

    respond_to do |format|
      format.html { render :index }
      format.csv do
        Asset.transaction do
          send_data current_user.is_support? ? @assets.to_support_csv : @assets.to_non_support_csv
          @assets.each { |asset| set_first_viewed_at_if_should_update_first_viewed_at(asset) }
        end
      end
    end
  end

  # GET /assets/1
  def show
    set_first_viewed_at_if_should_update_first_viewed_at(@asset)
  end

private

  def set_first_viewed_at_if_should_update_first_viewed_at(asset)
    asset.update!(first_viewed_at: Time.zone.now) if should_update_first_viewed_at?(asset)
  end

  def should_update_first_viewed_at?(asset)
    current_user_counts_as_viewer_and_asset_unseen?(asset)
  end

  def current_user_counts_as_viewer_and_asset_unseen?(asset)
    current_user_counts_as_viewer? && !asset.viewed?
  end

  def current_user_counts_as_viewer?
    !current_user.is_support?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_asset
    @asset = policy_scope(Asset).find(params[:id])
  end
end
