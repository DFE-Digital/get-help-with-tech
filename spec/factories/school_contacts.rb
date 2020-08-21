FactoryBot.define do
  factory :school_contact do
    school
    full_name { Faker::Name.unique.name }
    email_address { Faker::Internet.unique.email }
    role { 'headteacher' }
    title { 'Headteacher' }
    phone_number { Faker::PhoneNumber.phone_number }
  end
end
