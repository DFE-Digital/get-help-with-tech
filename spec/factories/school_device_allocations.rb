FactoryBot.define do
  factory :school_device_allocation do
    association :school
    association :created_by_user, factory: :dfe_user
    association :last_updated_by_user, factory: :dfe_user
    device_type { SchoolDeviceAllocation.device_types.keys.sample }
  end
end
