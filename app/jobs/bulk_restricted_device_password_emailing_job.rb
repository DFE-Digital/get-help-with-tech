class BulkRestrictedDevicePasswordEmailingJob < ApplicationJob
  queue_as :default

  ALL_SETTINGS = :all

  def perform(rb_limit: ALL_SETTINGS, school_limit: ALL_SETTINGS)
    @rb_limit = rb_limit
    @school_limit = school_limit
    schedule_settings(rbs)
    schedule_settings(schools)
  end

private

  attr_reader :rb_limit, :rbs, :school_limit, :schools

  def rb_limit?
    rb_limit != ALL_SETTINGS
  end

  def school_limit?
    school_limit != ALL_SETTINGS
  end

  def rbs
    return @rbs if instance_variable_defined?(:@rbs)

    query = ResponsibleBody.with_restricted_devices_and_users
    @rbs = rb_limit? ? query.limit(rb_limit) : query
  end

  def schools
    return @schools if instance_variable_defined?(:@schools)

    query = School.with_restricted_devices_and_users
    @schools = school_limit? ? query.limit(school_limit) : query
  end

  def schedule_settings(settings)
    settings.find_each do |setting|
      RestrictedDevicePasswordEmailingForSettingJob.perform_later(
        setting_id: setting.id,
        setting_classname: setting.class.name
      )
    end
  end
end
