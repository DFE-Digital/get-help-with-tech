FactoryBot.define do
  factory :reportable_event do
    trait :extra_mobile_data_request_completion do
      event_name { 'completion' }
      association(:record, factory: :extra_mobile_data_request)
      event_time { Time.zone.now.utc }
    end
  end
end
