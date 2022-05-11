FactoryBot.define do
  factory :computacenter_order, class: 'Computacenter::Order' do
    source { "Wave #{Faker::Number.unique.number(digits: 1)}" }
    sold_to { "81#{Faker::Number.unique.number(digits: 6)}" }
    ship_to { "81#{Faker::Number.unique.number(digits: 6)}" }
    sales_order_number { 5_000_000_000 + Faker::Number.unique.number(digits: 9) }
    persona { 'Chrome laptop' }
    material_number { 4_100_000 + Faker::Number.unique.number(digits: 5) }
    material_description { ':DFE:Dell Chrmbk3100 CelN4000 4/16 11 DD' }
    manufacturer { 'DELL Technologies' }
    quantity_ordered { 1 }
    quantity_outstanding { 0 }
    quantity_completed { 1 }
    order_date { Date.strptime('5/15/2020', '%m/%d/%Y') }
    despatch_date { Date.strptime('5/18/2020', '%m/%d/%Y') }
    order_completed { true }
    is_return { false }
    customer_order_number { "HYB-8#{Faker::Number.unique.number(digits: 7)}" }
    raw_order { build(:computacenter_raw_order) }
  end
end
