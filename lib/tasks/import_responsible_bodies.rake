namespace :import do
  desc 'Import local authorities in England'
  task local_authorities_in_england: :environment do
    ImportResponsibleBodiesService.new.import_local_authorities
  end

  desc 'Import single and multi-academy trusts'
  task trusts: :environment do
    ImportResponsibleBodiesService.new.import_trusts
  end

  desc 'Populate the responsible body reference data table'
  task responsible_bodies: %i[local_authorities_in_england trusts]
end
