require 'csv'

module AwsS3Helper
  def stub_s3
    allow(Aws::S3::Client).to receive(:new).and_return(Aws::S3::Client.new(stub_responses: true))
  end

  def stub_file_storage(file)
    allow(Aws::S3::Client).to receive(:new).and_return(
      Aws::S3::Client.new(stub_responses: {
        create_bucket: { location: 'Location' },
        put_object: { etag: 'Etag' },
        list_buckets: { buckets: [{ name: Settings.aws.s3.bulk_allocation_uploads_bucket }] },
        get_object: { etag: 'Etag', body: file.read },
      }),
    )
  end
end

RSpec.configure do |c|
  c.include AwsS3Helper
end
