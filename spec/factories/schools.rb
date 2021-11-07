FactoryBot.define do
  factory :school, class: 'CompulsorySchool' do
    transient do
      laptops { [0, 0, 0] }
      routers { [0, 0, 0] }
    end

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

    raw_laptop_allocation { laptops[0].to_i }
    circumstances_laptops { can_order_for_specific_circumstances? ? laptops[1].to_i - raw_laptop_allocation : 0 }
    over_order_reclaimed_laptops { can_order_for_specific_circumstances? ? 0 : laptops[1].to_i - raw_laptop_allocation }
    raw_laptops_ordered { laptops[2].to_i }

    raw_router_allocation { routers[0].to_i }
    circumstances_routers { can_order_for_specific_circumstances? ? routers[1].to_i - raw_router_allocation : 0 }
    over_order_reclaimed_routers { can_order_for_specific_circumstances? ? 0 : routers[1].to_i - raw_router_allocation }
    raw_routers_ordered { routers[2].to_i }

    trait :does_not_need_chromebooks do
      will_need_chromebooks { 'no' }
    end

    trait :dont_know_they_need_chromebooks do
      will_need_chromebooks { 'i_dont_know' }
    end

    trait :with_preorder_information do
      who_will_order_devices { %w[school responsible_body].sample }
      preorder_status { instance.send(:infer_status) }
    end

    trait :manages_orders do
      who_will_order_devices { 'school' }
      preorder_status { instance.send(:infer_status) }
    end

    trait :needs_chromebooks do
      will_need_chromebooks { 'yes' }
      school_or_rb_domain { Faker::Internet.domain_name }
      recovery_email_address { Faker::Internet.email }
    end

    trait :centrally_managed do
      who_will_order_devices { 'responsible_body' }
      preorder_status { instance.send(:infer_status) }
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
