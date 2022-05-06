FactoryBot.define do
  factory :computacenter_raw_order, class: 'Computacenter::RawOrder' do
    source { 'Wave 1' }
    responsible_body { 'East Sussex' }
    urn_cc { 'SC845' }
    category { 'Social care' }
    sold_to_account_no { '81000001' }
    sold_to_customer { 'East Sussex Social Care' }
    ship_to_urn { '845' }
    ship_to_account_no { '81000002' }
    ship_to_customer { '845 East Sussex Social Care' }
    sales_order_number { '5000000001' }
    persona_cleaned { 'Chrome laptop' }
    material_number { '4100001' }
    material_description { ':DFE:Dell Chrmbk3100 CelN4000 4/16 11 DD' }
    manufacturer_cleaned { 'DELL Technologies' }
    quantity_ordered { '1' }
    quantity_outstanding { '' }
    quantity_completed { '1' }
    order_date { '5/15/2020' }
    despatch_date { '5/18/2020' }
    order_completed { 'TRUE' }
    is_return { 'FALSE' }
    customer_order_number { 'HYB-80000001' }
    processed_at { nil }

    trait :processed do
      processed_at { Time.zone.now }
    end

    trait :updated do
      processed_at { Time.zone.now - 1.day }
    end
  end
end
