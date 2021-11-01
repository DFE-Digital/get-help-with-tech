require 'csv'

class Support::BulkAllocationForm
  include ActiveModel::Model

  CSV_HEADERS = %w[urn ukprn allocation_delta order_state].freeze

  attr_accessor :upload
  attr_reader :send_notification

  validates :upload, presence: { message: 'Select a CSV to upload' }
  validates :send_notification, inclusion: { in: [true, false], message: 'Select whether or not to send user notifications' }

  def save
    valid? && upload_scheduled?
  end

  def send_notification=(value)
    @send_notification = ActiveModel::Type::Boolean.new.cast(value)
  end

  def batch_id
    @batch_id ||= SecureRandom.uuid
  end

private

  def add_school_for_post_processing_of_vcaps(school)
    vcaps_for_post_processing[school.responsible_body_id] += 1
  end

  def create_allocation_batch_job(props)
    job_attrs = props.merge(batch_id: batch_id, send_notification: send_notification)
    AllocationBatchJob.create!(job_attrs)
  end

  def post_process_vcaps
    vcaps_for_post_processing.each_key do |responsible_body_id|
      CalculateVcapJob.perform_later(responsible_body_id: responsible_body_id,
                                     batch_id: batch_id,
                                     notify_school: send_notification)
    end
  end

  def rows
    @rows ||= CSV.read(upload.path, headers: true)
  end

  def schedule_school(school, props)
    allocation_batch_job = create_allocation_batch_job(props)
    if school.in_virtual_cap_pool?
      add_school_for_post_processing_of_vcaps(school)
    else
      AllocationJob.perform_later(allocation_batch_job)
    end
  end

  def upload_scheduled?
    rows.each do |row|
      props = row.to_h.slice(*CSV_HEADERS).symbolize_keys!
      school = School.where_urn_or_ukprn_or_provision_urn(props[:urn] || props[:ukprn]).first
      schedule_school(school, props) if school
    end
    post_process_vcaps
    true
  rescue StandardError
    false
  end

  def vcaps_for_post_processing
    @vcaps_for_post_processing ||= Hash.new { |hash, key| hash[key] = 0 }
  end
end
