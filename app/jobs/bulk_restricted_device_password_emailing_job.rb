class BulkRestrictedDevicePasswordEmailingJob < ApplicationJob
  queue_as :default

  ALL_SETTINGS = :all

  def perform(number_of_rbs: ALL_SETTINGS, number_of_schools: ALL_SETTINGS, rb_offset: 0, school_offset: 0)
    @number_of_rbs = number_of_rbs
    @number_of_schools = number_of_schools
    @rb_offset = rb_offset
    @school_offset = school_offset
    schedule_settings(rbs)
    schedule_settings(schools)
  end

private

  attr_reader :number_of_rbs, :number_of_schools, :rb_offset, :school_offset

  def all_rbs?
    number_of_rbs == ALL_SETTINGS
  end

  def all_schools?
    number_of_schools == ALL_SETTINGS
  end

  def rbs
    @rbs ||= all_rbs? ? eligible_rbs : eligible_rbs.limit(number_of_rbs)
  end

  def eligible_rbs
    ResponsibleBody.with_restricted_devices_and_users.offset(rb_offset)
  end

  def schools
    @schools ||= all_schools? ? eligible_schools : eligible_schools.limit(number_of_schools)
  end

  def eligible_schools
    School.with_restricted_devices_and_users.offset(school_offset)
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
