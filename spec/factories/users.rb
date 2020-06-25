FactoryBot.define do
  factory :local_authority_user, class: 'User' do
    full_name     { 'Jane Doe' }
    email_address { 'jane.doe@somelocalauthority.gov.uk' }
    organisation  { 'Some Local Authority' }
    approved_at   { Time.now.utc - 3.days }
  end

  factory :mno_user, class: 'User' do
    full_name     { 'Mike Mobile-Network' }
    email_address { 'mike.mobile-network@somemno.co.uk' }
    organisation  { 'Participating Mobile Network' }
    association   :mobile_network
  end
end
