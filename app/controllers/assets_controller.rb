require 'search_serial_number_parser'

class AssetsController < ApplicationController
  before_action :require_sign_in!
  before_action :set_asset, only: %i[show bios_unlocker]

  BIOS_UNLOCKER_FILE = Rails.root.join('private/BIOS_Unlocker.exe')

  # A high number may cause timeouts by the reverse proxy
  # due to decryption of passwords speeds
  MAX_ASSET_COUNT_EMAIL_CSV_DOWNLOAD = 50

  # GET /assets
  def index
    asset_service = AssetsService.new(user: current_user)

    if params[:serial_number].blank?
      @title = 'View your device details'
      asset_service.setting = setting
    else
      @current_serial_number_search = params[:serial_number]
      @title = 'Search results'
      asset_service.serial_numbers = serial_numbers_for_user_role
    end

    @assets = asset_service.assets
    @multiple_serial_number_search = allow_multiple_serial_number_search?

    respond_to do |format|
      format.html
      format.csv do
        if @assets.size <= MAX_ASSET_COUNT_EMAIL_CSV_DOWNLOAD
          send_data asset_service.assets_csv, filename: "devices--#{Time.zone.now.strftime('%y-%m-%d-%H%M%S')}.csv"
        else
          flash[:info] = 'Your export is in progress. Please note, large files can take up to 1 hour to generate. You’ll receive an email when your export is ready to download.'
          asset_service.assets_csv_via_email
          redirect_to assets_path
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

  def download
    @download = current_user.downloads.find_by_uuid(params[:uuid])
    render :download_expired and return unless @download

    respond_to do |format|
      format.html
      format.csv do
        @download.downloaded!
        send_data @download.content, filename: @download.filename
      end
    end
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
