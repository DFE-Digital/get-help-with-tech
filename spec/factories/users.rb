FactoryBot.define do
  factory :local_authority_user, class: User do
    full_name     { 'Jane Doe' }
    email_address { 'jane.doe@somelocalauthority.gov.uk' }
    organisation  { 'Some Local Authority' }
  end
end
