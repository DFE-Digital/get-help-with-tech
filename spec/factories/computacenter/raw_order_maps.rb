FactoryBot.define do
  factory :computacenter_raw_order_map, class: 'Computacenter::RawOrderMap' do
    raw_order { build(:computacenter_raw_order) }

    skip_create
    initialize_with { new(raw_order:) }
  end
end
