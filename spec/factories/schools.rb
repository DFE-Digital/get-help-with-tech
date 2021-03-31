FactoryBot.define do
  factory :school, class: 'CompulsorySchool' do
    factory :fe_school, class: 'FurtherEducationSchool' do
      association :responsible_body, factory: :further_education_college
      ukprn { Faker::Number.unique.number(digits: 8) }
      urn { nil }
    end

    association :responsible_body, factory: %i[local_authority trust].sample
    urn { Faker::Number.unique.number(digits: 6) }
    sequence(:name) { |n| "#{Faker::Educator.secondary_school}-#{n}" }
    computacenter_reference { Faker::Number.number(digits: 8) }
    phase { School.phases.values.sample }
    establishment_type { School.establishment_types.values.sample }

    address_1 { Faker::Address.street_name }
    address_2 { Faker::Address.secondary_address }
    town { Faker::Address.city }
    postcode { Faker::Address.postcode }

    trait :with_preorder_information do
      preorder_information { association :preorder_information, school: instance }
    end

    trait :manages_orders do
      preorder_information { association :preorder_information, :school_will_order, school: instance }
    end

    trait :centrally_managed do
      preorder_information { association :preorder_information, :rb_will_order, school: instance }
    end

    trait :with_headteacher_contact do
      after :create do |school|
        school.contacts << create(:school_contact, :headteacher)
      end
    end

    trait :primary do
      phase { :primary }
    end

    trait :secondary do
      phase { :secondary }
    end

    trait :academy do
      establishment_type { :academy }
      association :responsible_body, factory: :trust
    end

    trait :la_maintained do
      establishment_type { :local_authority }
      association :responsible_body, factory: :local_authority
    end

    trait :with_std_device_allocation do
      std_device_allocation { association :school_device_allocation, :with_std_allocation, school: instance }
    end

    trait :with_coms_device_allocation do
      coms_device_allocation { association :school_device_allocation, :with_coms_allocation, school: instance }
    end

    trait :can_order_for_specific_circumstances do
      order_state { 'can_order_for_specific_circumstances' }
    end

    trait :in_lockdown do
      order_state { 'can_order' }
    end
  end
end
