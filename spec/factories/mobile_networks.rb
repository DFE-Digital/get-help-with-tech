FactoryBot.define do
  factory :participating_mobile_network, class: MobileNetwork do
    brand                   { 'Participating mobile network' }
    host_network            { 'AA' }
    participating_in_scheme { true }
  end
end
