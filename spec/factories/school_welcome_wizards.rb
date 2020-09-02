FactoryBot.define do
  factory :school_welcome_wizard do
    user { create(:school_user) }
    step { 'welcome' }

    trait :completed do
      step { 'complete' }
    end
  end
end
