FactoryBot.define do
  factory :user_change, class: 'Computacenter::UserChange' do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email_address { Faker::Internet.unique.email }
    telephone { [Faker::PhoneNumber.phone_number, Faker::PhoneNumber.cell_phone].sample }
    responsible_body { [Faker::Address.county, LocalAuthority.organisation_types.values.sample].join(' ') }
    responsible_body_urn { "LEA#{Faker::Number.number(digits: 3)}" }
    cc_sold_to_number { Faker::Number.number(digits: 8) }
    school { Faker::Educator.secondary_school }
    school_urn { Faker::Number.number(digits: 6) }
    cc_ship_to_number { Faker::Number.number(digits: 8) }
    updated_at_timestamp { Time.zone.now.utc }
    type_of_update { 'Change' }
    # these fields may or may not be populated depending on the change
    original_first_name { nil }
    original_last_name { nil }
    original_email_address { nil }
    original_telephone { nil }
    original_responsible_body { nil }
    original_responsible_body_urn { nil }
    original_cc_sold_to_number { nil }
    original_school { nil }
    original_school_urn { nil }
    original_cc_ship_to_number { nil }

    trait :new_local_authority_user do
      responsible_body { [Faker::Address.county, LocalAuthority.organisation_types.values.sample].join(' ') }
      responsible_body_urn { "LEA#{Faker::Number.number(digits: 3)}" }
      cc_sold_to_number { Faker::Number.number(digits: 8) }
      school { nil }
      school_urn { nil }
      cc_ship_to_number { nil }
      updated_at_timestamp { Time.zone.now.utc }
      type_of_update { 'New' }
    end

    trait :school_user do
      school { Faker::Educator.secondary_school }
      school_urn { Faker::Number.number(digits: 6) }
      cc_ship_to_number { Faker::Number.number(digits: 8) }
      responsible_body { [Faker::Address.county, LocalAuthority.organisation_types.values.sample].join(' ') }
      responsible_body_urn { "LEA#{Faker::Number.number(digits: 3)}" }
      cc_sold_to_number { Faker::Number.number(digits: 8) }
    end

    trait :school_unchanged do
      original_school { nil }
      original_school_urn { nil }
      original_cc_ship_to_number { nil }
    end

    trait :school_changed do
      original_school { Faker::Educator.secondary_school }
      original_school_urn { Faker::Number.number(digits: 6) }
      original_cc_ship_to_number { Faker::Number.number(digits: 8) }
    end

    trait :changed_telephone do
      telephone { [Faker::PhoneNumber.phone_number, Faker::PhoneNumber.cell_phone].sample }
      original_telephone { [Faker::PhoneNumber.phone_number, Faker::PhoneNumber.cell_phone].sample }
    end

    trait :changed_email_address do
      email_address { Faker::Internet.unique.email }
      original_email_address { Faker::Internet.unique.email }
    end
  end
end
