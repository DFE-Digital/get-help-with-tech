require 'csv'

class BulkAllocationJob < ApplicationJob
  queue_as :default

  CSV_HEADERS = %w[urn ukprn allocation allocation_delta order_state].freeze

  attr_reader :batch_id, :filename, :send_notification

  def perform(batch_id:, filename:, send_notification:)
    @batch_id = batch_id
    @filename = filename
    @send_notification = send_notification
    schedule_schools
  end

private

  attr_reader :download_response

  def add_school_for_post_processing_of_vcaps(school)
    vcaps_for_post_processing[school.responsible_body_id] += 1
  end

  def bucket_name
    @bucket_name ||= GhwtAws::S3_BUCKET_NAME
  end

  def cant_read_file
    Sentry.with_scope do |scope|
      scope.set_context('S3GetObjectResponse', download_response.to_h)
      Sentry.capture_message("Unable to store object #{filename} on S3 bucket #{bucket_name}!")
    end
    nil
  end

  def create_allocation_batch_job(school, props)
    allocation = props.delete(:allocation)
    props[:allocation_delta] = allocation.to_i - school.raw_allocation(:laptop) if allocation.present?
    job_attrs = props.merge(batch_id:, send_notification:)
    AllocationBatchJob.create!(job_attrs)
  end

  def download_file
    @download_response = s3.get_object(response_target: filename, bucket: bucket_name, key: filename) if s3
  end

  def file?
    (download_file&.etag || filename).present?
  end

  def post_process_vcaps
    vcaps_for_post_processing.each_key do |responsible_body_id|
      CalculateVcapJob.perform_later(responsible_body_id:,
                                     batch_id:,
                                     notify_school: send_notification)
    end
  end

  def read_file
    file? ? CSV.read(filename, headers: true) : cant_read_file
  end

  def rows
    @rows ||= read_file || []
  end

  def s3
    @s3 ||= GhwtAws::S3_CLIENT
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
  ensure
    File.delete(filename) if File.exist?(filename)
  end

  def vcaps_for_post_processing
    @vcaps_for_post_processing ||= Hash.new(0)
  end
end
