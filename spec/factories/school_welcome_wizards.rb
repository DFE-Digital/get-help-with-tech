FactoryBot.define do
  factory :school_welcome_wizard do
    user { create(:school_user) }
    step { 'allocation' }

    association :school

    trait :completed do
      step { 'complete' }
    end

    trait :first_user do
      first_school_user { true }
    end

    trait :subsequent_user do
      first_school_user { false }
    end
  end
end
