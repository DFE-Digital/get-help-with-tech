namespace :import do
  desc 'Ingest orders from CC for P45'
  task orders_ingest: :environment do
    Importers::Orders.new(ENV.fetch('ORDERS_FILE_PATH')).ingest
  end

  desc 'Process raw order data for P45'
  task orders_process: :environment do
    Importers::Orders.new(ENV.fetch('ORDERS_FILE_PATH')).process
  end

  desc 'Ingest serials from CC for P45'
  task serials_ingest: :environment do
    Importers::Serials.new(ENV.fetch('SERIALS_FILE_PATH')).ingest
  end

  desc 'Process raw serial data for P45'
  task serials_process: :environment do
    Importers::Serials.new(ENV.fetch('SERIALS_FILE_PATH')).process
  end
end
