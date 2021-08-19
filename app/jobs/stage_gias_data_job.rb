class StageGiasDataJob < ApplicationJob
  def perform
    return if paused?

    service = StageSchoolData.new

    ActiveRecord::Base.transaction do
      service.import_schools
      service.import_school_links
    end
  end

private

  def paused?
    FeatureFlag.active?(:gias_data_stage_pause)
  end
end
