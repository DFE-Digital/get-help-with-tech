FactoryBot.define do
  factory :devices_ordered_update, class: 'Computacenter::DevicesOrderedUpdate' do
    ship_to { Faker::Number.number(digits: 8) }
    cap_amount { Faker::Number.between(from: 50, to: 100) }
    cap_used { Faker::Number.between(from: 0, to: 100) }

    trait :laptop do
      cap_type { 'DfE_RemainThresholdQty|Std_Device' }
    end

    trait :router do
      cap_type { 'DfE_RemainThresholdQty|Coms_Device' }
    end
  end
end
