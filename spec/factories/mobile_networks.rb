FactoryBot.define do
  factory :mobile_network, class: 'MobileNetwork' do
    sequence(:brand)       { |n| "Participating mobile network #{n}" }
    host_network           { 'AA' }
    participation_in_pilot { :participating }

    trait :not_participating_in_pilot do
      participation_in_pilot { :not_participating }
    end

    trait :maybe_participating_in_pilot do
      participation_in_pilot { :maybe_participating }
    end
  end
end
