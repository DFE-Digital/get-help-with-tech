FactoryBot.define do
  factory :school_device_allocation do
    association :school
    association :created_by_user, factory: :dfe_user
    association :last_updated_by_user, factory: :dfe_user
    device_type { SchoolDeviceAllocation.device_types.keys.sample }

    trait :with_std_allocation do
      device_type { 'std_device' }
      allocation { Faker::Number.within(range: 1..100) }
      cap { 0 }
    end

    trait :with_available_devices do
      allocation { 100 }
      cap { Faker::Number.within(range: 10..50) }
    end

    trait :with_coms_allocation do
      device_type { 'coms_device' }
      allocation { Faker::Number.within(range: 1..100) }
      cap { 0 }
    end

    trait :with_orderable_devices do
      allocation { 100 }
      cap { Faker::Number.within(range: 20..80) }
    end

    trait :fully_ordered do
      allocation { 100 }
      cap { 100 }
      devices_ordered { 100 }
    end

    trait :partially_ordered do
      allocation { 100 }
      cap { 100 }
      devices_ordered { Faker::Number.within(range: 20..80) }
    end
  end
end
