FactoryBot.define do
  factory :user do
    full_name { Faker::Name.unique.name }
    email_address { Faker::Internet.unique.email }
    has_seen_privacy_notice

    trait :has_seen_privacy_notice do
      privacy_notice_seen_at { 3.days.ago }
    end

    trait :approved do
      approved_at { Time.zone.now.utc - 3.days }
    end

    trait :not_approved do
      approved_at { nil }
    end

    trait :never_signed_in do
      sign_in_count     { 0 }
      last_signed_in_at { nil }
    end

    trait :signed_in_before do
      sign_in_count     { 3 }
      last_signed_in_at { 2.days.ago }
    end

    trait :who_has_requested_a_magic_link do
      sign_in_token            { SecureRandom.uuid }
      sign_in_token_expires_at { 30.minutes.from_now }
    end

    factory :local_authority_user do
      association :responsible_body, factory: %i[local_authority in_connectivity_pilot]
      approved
    end

    factory :trust_user do
      association :responsible_body, factory: %i[trust in_connectivity_pilot]
      approved
    end

    factory :school_user do
      school
      orders_devices { false }
      has_completed_wizard

      trait :orders_devices do
        orders_devices { true }
      end

      trait :new_visitor do
        after(:create) do |user|
          user.school_welcome_wizard&.destroy!
          user.school_welcome_wizard = create(:school_welcome_wizard, user: user)
        end
      end

      trait :has_completed_wizard do
        after(:create) do |user|
          user.school_welcome_wizard ||= create(:school_welcome_wizard, :completed, user: user)
        end
      end
    end

    factory :mno_user do
      association :mobile_network
    end

    factory :dfe_user do
      is_support { true }
      email_address do
        full_name.downcase.gsub(' ', '.') + ['@digital.education.gov.uk', '@education.gov.uk'].sample
      end
    end

    factory :computacenter_user do
      is_computacenter { true }
      email_address do
        full_name.downcase.gsub(' ', '.') + '@computacenter.com'
      end
    end
  end
end
