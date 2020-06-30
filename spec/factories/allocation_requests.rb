FactoryBot.define do
  factory :allocation_request, class: 'AllocationRequest' do
    number_eligible                     { Faker::Number.between(from: 0, to: 100) }
    number_eligible_with_hotspot_access { Faker::Number.between(from: 0, to: number_eligible) }
    association :created_by_user, factory: :local_authority_user
  end
end
