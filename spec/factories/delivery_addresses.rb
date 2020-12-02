FactoryBot.define do
  factory :delivery_address do
    name { Faker::Company.name }
    address_1 { Faker::Address.street_name }
    address_2 { Faker::Address.secondary_address }
    town { Faker::Address.city }
    postcode { Faker::Address.postcode }
  end
end
