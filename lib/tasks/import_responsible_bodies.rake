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
end
