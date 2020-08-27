namespace :import do
  desc 'Import school device allocations from url specified in ALLOCATIONS_FILE_URL env-var'
  task allocations: :environment do
    ImportDeviceAllocationsService.import_from_url(ENV.fetch('ALLOCATIONS_FILE_URL'))
  end
end
