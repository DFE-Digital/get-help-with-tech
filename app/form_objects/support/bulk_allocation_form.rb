class Support::BulkAllocationForm
  include ActiveModel::Model

  attr_accessor :upload
  attr_reader :send_notification

  validates :upload, presence: { message: 'Select a CSV to upload' }
  validates :send_notification, inclusion: { in: [true, false], message: 'Select whether or not to send user notifications' }

  def batch_id
    @batch_id ||= SecureRandom.uuid
  end

  def save
    valid? && file_stored? && upload_scheduled?
  end

  def send_notification=(value)
    @send_notification = ActiveModel::Type::Boolean.new.cast(value)
  end

private

  def bucket_created?
    bucket_exists? || s3.create_bucket(bucket: bucket_name).location.present?
  end

  def bucket_exists?
    s3.list_buckets.buckets.any? { |bucket| bucket.name == bucket_name }
  end

  def bucket_name
    @bucket_name ||= GhwtAws::AWS_S3_BUCKET_NAME
  end

  def cant_store_file(response)
    Sentry.with_scope do |scope|
      scope.set_context('S3PutObjectResponse', response.to_h)
      Sentry.capture_message("Unable to store object #{filename} on S3 bucket #{bucket_name}!")
    end
    nil
  end

  def filename
    @filename ||= "tranche-#{batch_id}.csv"
  end

  def file_stored?
    return true unless s3

    bucket_created? && store_file
  end

  def store_file
    response = s3.put_object(bucket: bucket_name, key: filename, body: upload) if upload.respond_to?(:read)
    response&.etag.present? || cant_store_file(response)
  end

  def s3
    @s3 ||= GhwtAws::AWS_S3_CLIENT
  end

  def upload_scheduled?
    BulkAllocationJob.perform_later(filename: s3 ? filename : upload.path,
                                    batch_id: batch_id,
                                    send_notification: send_notification)
    true
  rescue StandardError
    false
  end
end
