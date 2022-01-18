require 'csv'

module AwsS3Helper
  def stub_file_storage(file)
    stub_const('GhwtAws::AWS_S3_CLIENT',
               Aws::S3::Client.new(
                 stub_responses: {
                   create_bucket: { location: 'Location' },
                   put_object: { etag: 'Etag' },
                   list_buckets: { buckets: [{ name: GhwtAws::AWS_S3_BUCKET_NAME }] },
                   get_object: { etag: 'Etag', body: file.read },
                 },
               ))
  end
end

RSpec.configure do |c|
  c.include AwsS3Helper
end
