FactoryBot.define do
  factory :school_in_rb_that_orders, parent: :school do
    transient do
      responsible_body { create(:responsible_body) }
    end

    after(:create) do |school, evaluator|
      school.preorder_information.responsible_body_will_order_devices!
      evaluator.responsible_body.add_school_to_virtual_cap_pools!(school)
    end
  end
end
