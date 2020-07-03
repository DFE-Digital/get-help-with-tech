FactoryBot.define do
  factory :mobile_network, class: 'MobileNetwork' do
    sequence(:brand)        { |n| "Participating mobile network #{n}" }
    host_network            { 'AA' }
    participation_in_pilot  { :yes }
  end
end
