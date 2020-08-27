FactoryBot.define do
  factory :local_authority do
    organisation_type             { LocalAuthority.organisation_types.values.sample }
    name                          { [Faker::Address.county, organisation_type].join(' ') }
    local_authority_official_name { [organisation_type, name].join(' of ') }
    local_authority_eng           { name.first(3).upcase }
    companies_house_number        { rand(99_999).to_s }
    gias_id                       { Faker::Number.number(digits: 3) }
    computacenter_reference       { Faker::Number.number(digits: 8) }

    trait :in_connectivity_pilot do
      in_connectivity_pilot       { true }
    end

    trait :in_devices_pilot do
      in_devices_pilot            { true }
    end
  end

  factory :trust do
    organisation_type             { Trust.organisation_types.values.sample }
    name                          { [Faker::App.name, organisation_type == 'Single academy trust' ? 'Academy' : 'Academies'].join(' ') }
    local_authority_official_name { nil }
    local_authority_eng           { nil }
    companies_house_number        { Faker::Number.leading_zero_number(digits: 8) }
    computacenter_reference       { Faker::Number.number(digits: 8) }

    trait :single_academy_trust do
      organisation_type           { :single_academy_trust }
    end

    trait :multi_academy_trust do
      organisation_type           { :multi_academy_trust }
    end

    trait :in_connectivity_pilot do
      in_connectivity_pilot       { true }
    end

    trait :in_devices_pilot do
      in_devices_pilot            { true }
    end
  end
end
