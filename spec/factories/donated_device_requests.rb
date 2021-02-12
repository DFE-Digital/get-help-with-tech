FactoryBot.define do
  factory :donated_device_request do
    user
    school
    units { 4 }

    trait :wants_laptops do
      device_types { %w[windows-laptop chromebook] }
    end

    trait :wants_tablets do
      device_types { %w[windows-tablet android-tablet ipad] }
    end
  end
end
