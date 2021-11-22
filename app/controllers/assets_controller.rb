require 'search_serial_number_parser'

class AssetsController < ApplicationController
  before_action :require_sign_in!
  before_action :set_asset, only: %i[show bios_unlocker]

  BIOS_UNLOCKER_FILE = Rails.root.join('private/BIOS_Unlocker.exe')

  # GET /assets
  def index
    if params[:serial_number].blank?
      @title = 'View your device details'
      @assets = policy_scope(Asset).owned_by(setting)
    else
      @current_serial_number_search = params[:serial_number]
      @title = 'Search results'
      @assets = policy_scope(Asset).search_by_serial_numbers(serial_numbers_for_user_role)
    end

    @multiple_serial_number_search = allow_multiple_serial_number_search?

    respond_to do |format|
      format.html
      format.csv do
        Asset.transaction do
          send_data support_user? ? @assets.to_support_csv : @assets.to_non_support_csv, filename: 'devices.csv'
          assets_requiring_updated_viewed_at = @assets.select { |asset| should_update_first_viewed_at?(asset) }
          policy_scope(Asset).where(id: assets_requiring_updated_viewed_at.pluck(:id)).update_all(first_viewed_at: Time.zone.now)
        end
      end
    end
  end

  # GET /assets/1
  def show
    set_first_viewed_at_if_should_update_first_viewed_at(@asset)
  end

  def bios_unlocker
    send_file(BIOS_UNLOCKER_FILE)
  end

private

  def setting
    user = impersonated_or_current_user

    if user.responsible_body_user?
      user.responsible_body
    elsif user.is_school_user?
      user.school
    end
  end

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
    !support_user?
  end

  def support_user?
    current_user.is_support?
  end

  def serial_numbers_for_user_role
    multiple_search_for_support_user_or_single_search_for_non_support_user
  end

  def multiple_search_for_support_user_or_single_search_for_non_support_user
    SearchSerialNumberParser.new(serial_numbers_string: @current_serial_number_search, multiple: allow_multiple_serial_number_search?).serial_numbers
  end

  def allow_multiple_serial_number_search?
    support_user?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_asset
    id = SlugChecksumService.verify_uid(params[:uid])
    @asset = policy_scope(Asset).find(id)
  end
end
