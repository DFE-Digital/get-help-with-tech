FactoryBot.define do
  factory :school_welcome_wizard do
    user { create(:school_user) }
    step { 'privacy' }

    trait :completed do
      step { 'complete' }
    end
  end
end
