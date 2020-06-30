namespace :import do
  desc 'Import local authorities in England'
  task local_authorities_in_england: :environment do
    LocalAuthoritiesInEnglandRegister.entries.each do |entry|
      LocalAuthority
        .where(local_authority_eng: entry['local-authority-eng'])
        .first_or_create!(
          name: entry['name'],
          organisation_type: entry['local-authority-type'],
          local_authority_official_name: entry['official-name'],
        )
    end
  end

  desc 'Import single and multi-academy trusts'
  task trusts: :environment do
    GetInformationAboutSchools.trusts_entries.each do |entry|
      Trust
        .where(companies_house_number: entry['Companies House Number'])
        .first_or_create!(
          name: entry['Group Name'],
          organisation_type: entry['Group Type'],
        )
    end
  end

  desc 'Populate the responsible body reference data table'
  task responsible_bodies: %i[local_authorities_in_england trusts]
end
