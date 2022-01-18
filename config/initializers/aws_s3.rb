require 'v_cap_services_config'

module GhwtAws
  s3_config = VCapServicesConfig.new.first_service_matching('aws-s3-bucket')

  AWS_S3_CLIENT = if Rails.env.test?
                    Aws::S3::Client.new(stub_responses: true)
                  elsif !Rails.env.development? && s3_config
                    Aws::S3::Client.new(access_key_id: s3_config['credentials']['aws_access_key_id'],
                                        secret_access_key: s3_config['credentials']['aws_secret_access_key'],
                                        region: s3_config['credentials']['aws_region'])
                  end

  AWS_S3_BUCKET_NAME = if Rails.env.test?
                         'bulk_allocation_uploads'
                       elsif !Rails.env.development? && s3_config
                         s3_config['credentials']['bucket_name']
                       end
end
