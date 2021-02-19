FactoryBot.define do
  factory :donated_device_request do
    user

    trait :for_responsible_body do
      association :responsible_body, factory: %i[local_authority trust].sample
    end

    trait :opt_in_all do
      opt_in_choice { 'all_schools' }
    end

    trait :opt_in_some do
      opt_in_choice { 'some_schools' }
    end

    trait :wants_laptops do
      device_types { %w[windows chromebook] }
    end

    trait :wants_tablets do
      device_types { %w[android-tablet ipad] }
    end

    trait :wants_full_amount do
      units { 4 }
    end

    trait :complete do
      status { 'complete' }
    end
  end
end
