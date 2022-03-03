class DownloadsMailer < ApplicationMailer
  def notify_asset_download_ready
    download = params[:download]

    template_mail(
      Settings.govuk_notify.templates.devices.asset_download_ready,
      to: download.user.email_address,
      personalisation: { link_to_download: url(:assets_download_url, uuid: download.uuid) },
    )
  end
end
