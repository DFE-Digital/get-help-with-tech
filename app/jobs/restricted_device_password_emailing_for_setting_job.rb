class RestrictedDevicePasswordEmailingForSettingJob < ApplicationJob
  queue_as :default

  def perform(setting_classname:, setting_id:)
    @setting = setting_classname.constantize.find(setting_id)
    email_users
  end

private

  attr_reader :setting

  def data
    @data ||= StringIO.new(setting.assets.to_closure_notification_csv)
  end

  def link_to_file
    @link_to_file ||= Notifications.prepare_upload(data, true)
  end

  def email_users
    users.find_each do |user|
      RestrictedDevicePasswordsMailer
        .with(user:, organisation_name:, link_to_file:)
        .send(:notify_restricted_devices)
        .deliver_later
    end
  end

  def organisation_name
    setting.name
  end

  def users
    @users ||= setting.users.accepting_restricted_devices_comms
  end
end
