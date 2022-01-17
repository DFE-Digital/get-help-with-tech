require 'csv'

class BulkAllocationJob < ApplicationJob
  queue_as :default

  CSV_HEADERS = %w[urn ukprn allocation allocation_delta order_state].freeze

  attr_reader :batch_id, :filepath, :send_notification

  def perform(batch_id:, filepath:, send_notification:)
    @batch_id = batch_id
    @filepath = filepath
    @send_notification = send_notification
    schedule_schools
  end

private

  def add_school_for_post_processing_of_vcaps(school)
    vcaps_for_post_processing[school.responsible_body_id] += 1
  end

  def create_allocation_batch_job(school, props)
    allocation = props.delete(:allocation)
    props[:allocation_delta] = allocation.to_i - school.raw_allocation(:laptop) if allocation.present?
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
    @rows ||= CSV.read(filepath, headers: true)
  end

  def schedule_school(school, props)
    allocation_batch_job = create_allocation_batch_job(school, props)
    if school.vcap?
      add_school_for_post_processing_of_vcaps(school)
    else
      AllocationJob.perform_later(allocation_batch_job)
    end
  end

  def schedule_schools
    Rails.logger.info("BatchID: #{batch_id} - #{rows.count} rows")
    rows.each do |row|
      props = row.to_h.slice(*CSV_HEADERS).symbolize_keys!
      school = School.where_urn_or_ukprn_or_provision_urn(props[:urn] || props[:ukprn]).first
      schedule_school(school, props) if school
    end
    post_process_vcaps
    true
  rescue StandardError => e
    logger.error(e)
    Sentry.capture_exception(e)
    false
  end

  def vcaps_for_post_processing
    @vcaps_for_post_processing ||= Hash.new(0)
  end
end
