class ImportDeviceAllocationsService
  attr_reader :datasource

  def initialize(allocations_datasource)
    @datasource = allocations_datasource
  end

  def import_laptop_allocations
    datasource.allocations do |allocation|
      school = School.find_by(urn: allocation[:urn])

      if school
        UpdateSchoolDevicesService.new(school:,
                                       laptop_allocation: allocation[:y3_10],
                                       cap_change_category: :import_device_allocations).call
      else
        Rails.logger.warn("Could not find school (#{allocation[:urn]} - #{allocation[:name]})")
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.message)
    end
  end

  def self.import_from_url(url)
    file = Tempfile.new
    RemoteFile.download(url, file)
    new(AllocationDataFile.new(file.path)).import_laptop_allocations
  ensure
    file.close
    file.unlink
  end
end
