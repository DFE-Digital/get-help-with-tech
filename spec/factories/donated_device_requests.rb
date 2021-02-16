FactoryBot.define do
  factory :donated_device_request do
    user
    association :responsible_body, factory: %i[local_authority trust].sample
    units { 4 }

    trait :wants_laptops do
      device_types { %w[windows chromebook] }
    end

    trait :wants_tablets do
      device_types { %w[android-tablet ipad] }
    end

    trait :complete do
      status { 'complete' }
    end
  end
end
