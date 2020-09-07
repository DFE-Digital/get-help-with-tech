FactoryBot.define do
  factory :preorder_information do
    school
    who_will_order_devices { %w[school responsible_body].sample }
    status { infer_status }

    trait :needs_chromebooks do
      will_need_chromebooks { 'yes' }
      school_or_rb_domain { Faker::Internet.domain_name }
      recovery_email_address { Faker::Internet.email }
    end

    trait :does_not_need_chromebooks do
      will_need_chromebooks { 'no' }
    end
  end
end
