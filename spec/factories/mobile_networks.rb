FactoryBot.define do
  factory :mobile_network, class: 'MobileNetwork' do
    sequence(:brand)       { |n| "Participating mobile network #{n}" }
    host_network           { 'AA' }
    participation_in_pilot { MobileNetwork.participation_in_pilots.key('yes') }

    trait :not_participating_in_pilot do
      participation_in_pilot { MobileNetwork.participation_in_pilots.key('no') }
    end

    trait :maybe_participating_in_pilot do
      participation_in_pilot { MobileNetwork.participation_in_pilots.key('maybe') }
    end
  end
end
