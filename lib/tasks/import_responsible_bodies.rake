namespace :import do
  desc 'Import local authorities in England'
  task local_authorities_in_england: :environment do
    puts 'Import local authorities in England'
    ImportResponsibleBodiesService.new.import_local_authorities
  end

  desc 'Import local authority GIAS IDs'
  task local_authority_gias_ids: :environment do
    puts 'Import local authority GIAS IDs'
    CsvImportService.import!(
      LocalAuthorityGiasIdsDataFile.new(Rails.root.join('config/local_authority_data.csv')),
    )
  end

  desc 'Import single and multi-academy trusts'
  task trusts: :environment do
    puts 'Import single and multi-academy trusts'
    ImportResponsibleBodiesService.new.import_trusts
  end

  desc 'Import DfE as a responsible body for direct connectivity distribution'
  task dfe_as_a_responsible_body: :environment do
    puts 'Import DfE as a responsible body for direct connectivity distribution'
    ImportResponsibleBodiesService.new.import_dfe
  end

  desc 'Populate the responsible body reference data table'
  task responsible_bodies: %i[local_authorities_in_england local_authority_gias_ids trusts dfe_as_a_responsible_body]
end
