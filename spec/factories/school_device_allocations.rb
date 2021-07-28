FactoryBot.define do
  factory :school_device_allocation do
    std
    association :school
    association :created_by_user, factory: :dfe_user
    association :last_updated_by_user, factory: :dfe_user

    trait :std do
      device_type { 'std_device' }
    end

    trait :coms do
      device_type { 'coms_device' }
    end

    trait :with_std_allocation do
      allocation { 1 }
      cap { 0 }
    end

    trait :with_coms_allocation do
      coms
      allocation { 1 }
      cap { 0 }
    end

    trait :with_available_devices do
      allocation { 2 }
      cap { 1 }
    end

    trait :fully_ordered do
      allocation { 1 }
      cap { 1 }
      devices_ordered { 1 }
    end

    trait :partially_ordered do
      allocation { 2 }
      cap { 2 }
      devices_ordered { 1 }
    end
  end
end
