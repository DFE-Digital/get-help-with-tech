class AssetExportJob < ApplicationJob
  queue_as :default

  def perform(user_id:, serial_numbers: nil, setting_clazz: nil, setting_id: nil)
    @user = User.find_by_id(user_id)
    @serial_numbers = serial_numbers ? serial_numbers.split(',') : nil
    @setting = setting_id && setting_clazz ? setting_clazz.constantize.find_by_id(setting_id) : nil

    asset_service = AssetsService.new(user: @user, serial_numbers: @serial_numbers, setting: @setting)

    csv_data = asset_service.assets_csv

    uuid = SecureRandom.uuid

    download = Download.create!(
      uuid:,
      user: @user,
      tag: 'asset_csv_export',
      filetype: 'csv',
      filename: "devices--#{Time.zone.now.strftime('%y-%m-%d-%H%M%S')}--#{uuid}.csv",
      content: csv_data,
    )

    DownloadsMailer.with(download:).notify_asset_download_ready.deliver_later
  end
end
