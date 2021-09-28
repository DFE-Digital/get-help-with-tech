FactoryBot.define do
  factory :school, class: 'CompulsorySchool' do
    factory :fe_school, class: 'FurtherEducationSchool' do
      association :responsible_body, factory: :further_education_college
      ukprn { Faker::Number.unique.number(digits: 8) }
      urn { nil }
    end

    factory :iss_provision, class: 'LaFundedPlace' do
      association :responsible_body, factory: :local_authority
      establishment_type { 'la_funded_place' }
      name { 'State-funded pupils in independent special schools and alternative provision' }
      provision_type { 'iss' }
      provision_urn { "ISS#{responsible_body.gias_id}" }
    end

    factory :scl_provision, class: 'LaFundedPlace' do
      association :responsible_body, factory: :local_authority
      establishment_type { 'la_funded_place' }
      name { 'Care leavers' }
      provision_type { 'scl' }
      provision_urn { "SCL#{responsible_body.gias_id}" }
    end

    association :responsible_body, factory: %i[local_authority trust].sample
    urn { Faker::Number.unique.number(digits: 6) }
    sequence(:name) { |n| "#{Faker::Educator.secondary_school}-#{n}" }
    computacenter_reference { Faker::Number.number(digits: 8) }
    phase { School.phases.values.sample }
    establishment_type { (School.establishment_types.values - %w[la_funded_place]).sample }

    address_1 { Faker::Address.street_name }
    address_2 { Faker::Address.secondary_address }
    town { Faker::Address.city }
    postcode { Faker::Address.postcode }

    trait :with_preorder_information do
      preorder_information { association :preorder_information, school: instance }
    end

    trait :with_preorder_information_chromebooks do
      preorder_information { association :preorder_information, :needs_chromebooks, school: instance }
    end

    trait :manages_orders do
      preorder_information { association :preorder_information, :school_will_order, school: instance }
    end

    trait :centrally_managed do
      preorder_information { association :preorder_information, :rb_will_order, school: instance }
    end

    trait :with_headteacher do
      after :create do |school|
        school.contacts << create(:school_contact, :headteacher, school: school)
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
      transient do
        laptop_allocation { 1 }
        laptop_cap { 0 }
        laptops_ordered { 0 }
      end

      std_device_allocation do
        association :school_device_allocation,
                    :with_std_allocation,
                    school: instance,
                    laptop_allocation: laptop_allocation,
                    laptop_cap: laptop_cap,
                    laptops_ordered: laptops_ordered
      end
    end

    trait :with_std_device_allocation_fully_ordered do
      std_device_allocation { association :school_device_allocation, :with_std_allocation, :fully_ordered, school: instance }
    end

    trait :with_std_device_allocation_partially_ordered do
      std_device_allocation { association :school_device_allocation, :with_std_allocation, :partially_ordered, school: instance }
    end

    trait :with_coms_device_allocation do
      transient do
        router_allocation { 1 }
        router_cap { 0 }
        routers_ordered { 0 }
      end

      coms_device_allocation do
        association :school_device_allocation,
                    :with_coms_allocation,
                    school: instance,
                    router_allocation: router_allocation,
                    router_cap: router_cap,
                    routers_ordered: routers_ordered
      end
    end

    trait :with_coms_device_allocation_partially_ordered do
      coms_device_allocation { association :school_device_allocation, :with_coms_allocation, :partially_ordered, school: instance }
    end

    trait :can_order_for_specific_circumstances do
      order_state { 'can_order_for_specific_circumstances' }
    end

    trait :in_lockdown do
      order_state { 'can_order' }
    end

    trait :with_extra_mobile_data_requests do
      transient do
        extra_mobile_data_requests_count { 2 }
      end

      after(:create) do |school, evaluator|
        create_list(:extra_mobile_data_request, evaluator.extra_mobile_data_requests_count, status: 'complete', school: school)
        school.reload
      end
    end
  end
end
