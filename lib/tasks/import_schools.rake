namespace :import do
  desc 'Import schools from GIAS'
  task schools: :environment do
    ImportSchoolsService.new.import_schools
  end

  desc 'Import shipTo and sendTo from file at CC_REFERENCES_FILE_URI' do
    ImportComputacenterReferencesService.new(csv_uri: ENV['CC_REFERENCES_FILE_URI']).import
  end
end
