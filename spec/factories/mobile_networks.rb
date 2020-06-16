FactoryBot.define do
  factory :mobile_network, class: 'MobileNetwork' do
    brand                   { 'Participating mobile network' }
    host_network            { 'AA' }
    participating_in_scheme { true }
  end
end
