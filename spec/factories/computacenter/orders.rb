FactoryBot.define do
  factory :computacenter_order, class: 'Computacenter::Order' do
    source { 'Wave 1' }
    sold_to { 81_000_001 }
    ship_to { 81_000_002 }
    sales_order_number { 5_000_000_001 }
    persona { 'Chrome laptop' }
    material_number { 4_100_001 }
    material_description { ':DFE:Dell Chrmbk3100 CelN4000 4/16 11 DD' }
    manufacturer { 'DELL Technologies' }
    quantity_ordered { 1 }
    quantity_outstanding { 0 }
    quantity_completed { 1 }
    order_date { Date.strptime('5/15/2020', '%m/%d/%Y') }
    despatch_date { Date.strptime('5/18/2020', '%m/%d/%Y') }
    order_completed { true }
    is_return { false }
    customer_order_number { 'HYB-80000001' }
    raw_order { build(:computacenter_raw_order) }
  end
end
