namespace :import do
  desc 'Import schools from GIAS'
  task schools: :environment do
    puts 'Import schools from GIAS'
    StageGiasDataJob.perform_now
  end

  desc 'Process schools records from DataStage::School to School'
  task process_schools_data: :environment do
    service = SchoolUpdateService.new

    # TODO: Can be removed once we have data for these RB
    DataStage::School.gias_status_open.where('responsible_body_name like ?', '%Northampton%').destroy_all
    DataStage::School.gias_status_open.where('responsible_body_name like ?', '%Overseas Establishments%').destroy_all
    puts "Processing #{DataStage::School.gias_status_open.count} schools data"

    DataStage::School.gias_status_open.each do |staged|
      service.create_school!(staged)
    end
  end

  desc 'Import shipTo and sendTo from file at CC_REFERENCES_FILE_URI'
  task school_and_rb_computacenter_references: :environment do
    CsvImportService.import!(
      Computacenter::ShipToAndSoldToDataFile.new(ENV['CC_REFERENCES_FILE_URI']),
    )
  end
end
