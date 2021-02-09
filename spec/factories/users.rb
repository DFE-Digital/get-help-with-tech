FactoryBot.define do
  factory :user do
    full_name { Faker::Name.unique.name }
    email_address { Faker::Internet.unique.email }
    has_seen_privacy_notice
    telephone { [Faker::PhoneNumber.phone_number, Faker::PhoneNumber.cell_phone].sample }
    orders_devices { false }

    trait :has_seen_privacy_notice do
      privacy_notice_seen_at { 3.days.ago }
    end

    trait :has_not_seen_privacy_notice do
      privacy_notice_seen_at { nil }
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

    trait :deleted do
      deleted_at { 30.minutes.ago }
    end

    factory :local_authority_user do
      association :responsible_body, factory: %i[local_authority in_connectivity_pilot]
    end

    factory :trust_user do
      association :responsible_body, factory: %i[trust in_connectivity_pilot]
    end

    factory :single_academy_trust_user do
      association :responsible_body, factory: %i[trust single_academy_trust in_connectivity_pilot]
      school { build(:school, :academy, responsible_body: responsible_body) }
      orders_devices { true }
    end

    factory :fe_college_user do
      association :responsible_body, factory: %i[further_education_college in_connectivity_pilot]
      school { build(:fe_school, responsible_body: responsible_body) }
      orders_devices { true }
    end

    factory :school_user do
      transient do
        school { build(:school) }
      end
      after(:build) do |user, evaluator|
        user.schools << evaluator.school if user.schools.empty? && evaluator.school.present?
      end

      orders_devices { false }
      has_completed_wizard

      trait :orders_devices do
        orders_devices { true }
      end

      trait :new_visitor do
        after(:create) do |user|
          user.school_welcome_wizards&.destroy_all
          user.school_welcome_wizards << create(:school_welcome_wizard, user: user, school: user.school)
        end
      end

      trait :has_completed_wizard do
        after(:create) do |user|
          user.school_welcome_wizards << create(:school_welcome_wizard, :completed, user: user, school: user.school)
        end
      end

      trait :has_partially_completed_wizard do
        after(:create) do |user|
          user.school_welcome_wizards&.destroy_all
          user.school_welcome_wizards << create(:school_welcome_wizard, user: user, school: user.school, step: 'techsource_account')
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

    factory :support_user do
      is_support { true }
      email_address do
        full_name.downcase.gsub(' ', '.') + ['@digital.education.gov.uk', '@education.gov.uk'].sample
      end

      trait :third_line do
        role { 'third_line' }
      end
    end

    factory :computacenter_user do
      is_computacenter { true }
      email_address do
        full_name.downcase.gsub(' ', '.') + '@computacenter.com'
      end
    end

    trait :relevant_to_computacenter do
      has_seen_privacy_notice
      orders_devices { true }
    end

    trait :not_relevant_to_computacenter do
      has_not_seen_privacy_notice
      orders_devices { false }
    end

    trait :with_a_confirmed_techsource_account do
      techsource_account_confirmed_at { Time.zone.now }
    end
  end
end
