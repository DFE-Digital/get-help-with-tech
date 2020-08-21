FactoryBot.define do
  factory :preorder_information do
    school
    who_will_order_devices { %w[school responsible_body].sample }
    status { infer_status }
  end
end
