FactoryBot.define do
  factory :responsible_body do
    transient do
      laptops { [0, 0, 0] }
      routers { [0, 0, 0] }
    end

    laptop_allocation { laptops[0].to_i }
    laptop_cap { laptops[1].to_i }
    laptops_ordered { laptops[2].to_i }

    router_allocation { routers[0].to_i }
    router_cap { routers[1].to_i }
    routers_ordered { routers[2].to_i }

    computacenter_reference { Faker::Number.number(digits: 8) }
    status                  { 'open' }

    trait :manages_centrally do
      default_who_will_order_devices_for_schools { 'responsible_body' }
    end

    trait :devolves_management do
      default_who_will_order_devices_for_schools { 'school' }
    end

    trait :vcap do
      vcap { true }
    end

    trait :with_schools do
      transient do
        schools_count { 3 }
      end

      after(:create) do |responsible_body, evaluator|
        create_list(:school, evaluator.schools_count, responsible_body: responsible_body)
        responsible_body.reload
      end
    end

    trait :with_centrally_managed_schools do
      transient do
        schools_count { 3 }
      end

      after(:create) do |responsible_body, evaluator|
        create_list(:school, evaluator.schools_count, :centrally_managed, laptops: [2, 2, 1], responsible_body: responsible_body)
        responsible_body.reload
      end
    end

    trait :with_centrally_managed_schools_fully_ordered do
      transient do
        schools_count { 3 }
      end

      after(:create) do |responsible_body, evaluator|
        create_list(:school, evaluator.schools_count, :centrally_managed, laptops: [2, 2, 2], responsible_body: responsible_body)
        responsible_body.reload
      end
    end

    trait :with_extra_mobile_data_requests do
      transient do
        extra_mobile_data_requests_count { 3 }
      end

      after(:create) do |responsible_body, evaluator|
        create_list(:extra_mobile_data_request, evaluator.extra_mobile_data_requests_count, status: 'complete', responsible_body: responsible_body)
        responsible_body.reload
      end
    end
  end

  factory :local_authority, parent: :responsible_body, class: 'LocalAuthority' do
    organisation_type             { LocalAuthority.organisation_types.values.sample }
    name                          { [Faker::Address.unique.county, organisation_type, Faker::Number.unique.number(digits: 3)].join(' ') }
    local_authority_official_name { [organisation_type, name].join(' of ') }
    local_authority_eng           { name.first(3).upcase }
    gias_id                       { Faker::Number.unique.number(digits: 3) }
  end

  factory :trust, parent: :responsible_body, class: 'Trust' do
    organisation_type             { Trust.organisation_types.values.sample }
    name                          { [Faker::App.unique.name, organisation_type == 'Single academy trust' ? 'Academy' : 'Academies'].join(' ') }
    local_authority_official_name { nil }
    local_authority_eng           { nil }
    companies_house_number        { Faker::Number.leading_zero_number(digits: 8) }
    gias_group_uid                { [Faker::Number.unique.number(digits: 3), nil].sample }

    trait :single_academy_trust do
      organisation_type           { :single_academy_trust }
    end

    trait :multi_academy_trust do
      organisation_type           { :multi_academy_trust }
    end

    trait :closed do
      status { 'closed' }
    end
  end

  factory :further_education_college, parent: :responsible_body, class: 'FurtherEducationCollege' do
    type { 'FurtherEducationCollege' }
    name { [Faker::App.unique.name, 'FE College'].join(' ') }
    organisation_type { 'FurtherEducationSchool' }

    trait :new_fe_wave do
      new_fe_wave { true }
    end
  end
end
