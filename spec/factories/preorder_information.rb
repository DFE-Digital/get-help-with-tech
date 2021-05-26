FactoryBot.define do
  factory :preorder_information do
    school
    who_will_order_devices { %w[school responsible_body].sample }
    status { infer_status }

    trait :school_will_order do
      who_will_order_devices { 'school' }
    end

    trait :rb_will_order do
      who_will_order_devices { 'responsible_body' }
    end

    trait :needs_chromebooks do
      will_need_chromebooks { 'yes' }
      school_or_rb_domain { Faker::Internet.domain_name }
      recovery_email_address { Faker::Internet.email }
    end

    trait :does_not_need_chromebooks do
      will_need_chromebooks { 'no' }
    end

    trait :dont_know_they_need_chromebooks do
      will_need_chromebooks { 'i_dont_know' }
    end
  end
end
