namespace :import do
  desc 'Import schools from GIAS'
  task schools: :environment do
    ImportSchoolsService.new.import_schools
  end
end
