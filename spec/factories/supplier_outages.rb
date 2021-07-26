FactoryBot.define do
  factory :supplier_outage do
    in_the_future
  end

  trait :in_the_future do
    starts_in_the_future
    end_at { 2.weeks.from_now }
  end

  trait :current do
    starts_in_the_past
    end_at { 2.weeks.from_now }
  end

  trait :starts_in_the_future do
    start_at { 1.week.from_now }
  end

  trait :starts_in_the_past do
    start_at { 1.week.ago }
  end
end
