FactoryBot.define do
  trait :approved do
    approved_at   { Time.now.utc - 3.days }
  end

  trait :not_approved do
    approved_at   { nil }
  end

  trait :never_signed_in do
    sign_in_count     { 0 }
    last_signed_in_at { nil }
  end

  factory :local_authority_user, class: 'User' do
    full_name                { 'Jane Doe' }
    sequence(:email_address) { |n| "jane.doe#{n}@somelocalauthority.gov.uk" }
    association              :responsible_body, factory: :local_authority
    approved
  end

  factory :trust_user, class: 'User' do
    full_name                { 'Jane Doe' }
    sequence(:email_address) { |n| "jane.doe#{n}@somelocalauthority.gov.uk" }
    association              :responsible_body, factory: :trust
    approved
  end

  factory :mno_user, class: 'User' do
    full_name     { 'Mike Mobile-Network' }
    email_address { 'mike.mobile-network@somemno.co.uk' }
    association   :mobile_network
  end

  factory :dfe_user, class: 'User' do
    full_name     { 'Jane Doe' }
    email_address { 'jane.doe@digital.education.gov.uk' }
  end
end
