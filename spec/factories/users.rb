FactoryBot.define do
  trait :approved do
    approved_at   { Time.now.utc - 3.days }
  end

  trait :not_approved do
    approved_at   { nil }
  end

  factory :local_authority_user, class: 'User' do
    full_name                { 'Jane Doe' }
    sequence(:email_address) { |n| "jane.doe#{n}@somelocalauthority.gov.uk" }
    organisation             { 'Some Local Authority' }
    association              :responsible_body, factory: :local_authority
    approved
  end

  factory :mno_user, class: 'User' do
    full_name     { 'Mike Mobile-Network' }
    email_address { 'mike.mobile-network@somemno.co.uk' }
    organisation  { 'Participating Mobile Network' }
    association   :mobile_network
  end

  factory :dfe_user, class: 'User' do
    full_name     { 'Jane Doe' }
    email_address { 'jane.doe@digital.education.gov.uk' }
    organisation  { 'DfE' }
  end
end
