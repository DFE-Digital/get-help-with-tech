class BulkRestrictedDevicePasswordEmailingJob < ApplicationJob
  queue_as :default

  ALL_SETTINGS = :all

  def perform(number_of_rbs: ALL_SETTINGS, number_of_schools: ALL_SETTINGS)
    @number_of_rbs = number_of_rbs
    @number_of_schools = number_of_schools
    schedule_settings(rbs)
    schedule_settings(schools)
  end

private

  attr_reader :number_of_rbs, :number_of_schools

  def all_rbs?
    number_of_rbs == ALL_SETTINGS
  end

  def all_schools?
    number_of_schools == ALL_SETTINGS
  end

  def rbs
    @rbs ||= all_rbs? ? rb_users : rb_users.limit(number_of_rbs)
  end

  def rb_users
    ResponsibleBody.with_restricted_devices_and_users
  end

  def schools
    @schools ||= all_schools? ? school_users : school_users.limit(number_of_schools)
  end

  def school_users
    School.with_restricted_devices_and_users
  end

  def schedule_settings(settings)
    settings.find_each do |setting|
      RestrictedDevicePasswordEmailingForSettingJob.perform_later(
        setting_id: setting.id,
        setting_classname: setting.class.name,
      )
    end
  end
end
