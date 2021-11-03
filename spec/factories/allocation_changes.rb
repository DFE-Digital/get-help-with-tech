FactoryBot.define do
  factory :allocation_change do
    school_device_allocation
    category { 'increase' }
    delta { 1 }
    description { nil }

    trait :allocation_error_reversal do
      category { 'allocation_error_reversal' }
      delta { -1 }
    end

    trait :over_order do
      category { 'over_order' }
    end

    trait :service_closure do
      category { 'service_closure' }
      delta { -1 }
    end

    trait :unused_allocation_reclaim do
      category { 'unused_allocation_reclaim' }
      delta { -1 }
    end

    trait :increase_with_description do
      category { 'increase' }
      delta { 1 }
      description { 'Jan 2021 allocation increase' }
    end
  end
end
