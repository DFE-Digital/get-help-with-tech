namespace :import_orders do
  desc 'convert unprocessed RawOrders to Orders'
  task convert: :environment do
    Computacenter::ConvertRawOrdersService.call
  end

  desc 'Ingest the raw order data from a csv file'
  task ingest: :environment do
    Computacenter::ImportRawOrdersService.call(path: ENV.fetch('ORDERS_FILE_PATH'))
  end
end
