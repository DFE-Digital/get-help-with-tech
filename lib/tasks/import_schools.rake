namespace :import do
  desc 'Import schools from GIAS'
  task schools: :environment do
    ImportSchoolsService.new.import_schools
  end

  desc 'Import shipTo and sendTo from file at CC_REFERENCES_FILE_URI'
  task school_and_rb_computacenter_references: :environment do
    CsvImportService.import!(
      Computacenter::ShipToAndSoldToDataFile.new(ENV['CC_REFERENCES_FILE_URI']),
    )
  end
end
