class StageGiasDataJob < ApplicationJob
  def perform
    service = StageSchoolData.new

    ActiveRecord::Base.transaction do
      service.import_schools
      service.import_school_links
    end
  end
end
