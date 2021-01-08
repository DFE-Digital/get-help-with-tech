class Support::UrnsAndAllocationsForm
  include ActiveModel::Model

  attr_accessor :urns_and_allocations, :parsed_list

  validates :urns_and_allocations, presence: { message: 'Enter the school URNs and new allocations, one pair per line' }

  def initialize(args = {})
    @urns_and_allocations = args[:urns_and_allocations]
  end

  def parse_urns_and_allocations!
    return [] if urns_and_allocations.empty?

    @parsed_list = urns_and_allocations.split("\r\n")
                                        .map(&:strip)
                                        .reject(&:blank?)
                                        .map { |line| line.split(/[\s,]+/) }
                                        .map { |urn, allocation| { urn: urn, allocation: allocation } }
  end

  def process!
    job = BatchJob.new(job_name: 'adjust_allocations_for_many_schools', records: @parsed_list)

    job.process! do |record|
      process_record!(record)
    end

    job
  end

private

  def process_record!(record)
    school = School.find_by_urn(record[:urn])

    AllocationUpdater.new(school: school, device_type: 'std_device', value: record[:allocation]).call
  end
end
