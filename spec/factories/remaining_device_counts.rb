FactoryBot.define do
  factory :remaining_device_count do
    date_of_count { Faker::Date.between(from: 9.months.ago, to: 1.day.ago) }
    remaining_from_devolved_schools { Faker::Number.within(range: 100..2000) }
    remaining_from_managed_schools { Faker::Number.within(range: 100..2000) }
  end
end
