FactoryBot.define do
  factory :local_authority do
    organisation_type             { LocalAuthority::ORGANISATION_TYPES.sample }
    name                          { [Faker::Address.county, organisation_type].join(' ') }
    local_authority_official_name { [organisation_type, name].join(' of ') }
    local_authority_eng           { name.first(3).upcase }
    companies_house_number        { nil }
  end

  factory :trust do
    organisation_type             { Trust::ORGANISATION_TYPES.sample }
    name                          { [Faker::App.name, organisation_type == 'Single academy trust' ? 'Academy' : 'Academies'].join(' ') }
    local_authority_official_name { nil }
    local_authority_eng           { nil }
    companies_house_number        { Faker::Number.leading_zero_number(digits: 8) }
  end
end
