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
      transient do
        laptop_allocation { 1 }
        laptop_cap { 0 }
        laptops_ordered { 0 }
      end

      allocation { laptop_allocation }
      cap { laptop_cap }
      devices_ordered { laptops_ordered }
    end

    trait :with_coms_allocation do
      transient do
        router_allocation { 1 }
        router_cap { 0 }
        routers_ordered { 0 }
      end

      coms
      allocation { router_allocation }
      cap { router_cap }
      devices_ordered { routers_ordered }
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
