FactoryBot.define do
  factory :school_contact do
    trait :headteacher do
      role { 'headteacher' }
      title { 'Headteacher' }
    end

    trait :contact do
      role { 'contact' }
    end

    school
    full_name { Faker::Name.unique.name }
    email_address { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number }
    headteacher
  end
end
