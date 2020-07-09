namespace :import do
  desc 'Import BT Wifi vouchers'
  task :bt_wifi_vouchers, [:csv_url] => :environment do |_t, args|
    ImportBTWifiVouchersService.new(args[:csv_url]).call
  end

  desc 'Import BT Wifi voucher allocations'
  task :bt_wifi_voucher_allocations, [:csv_url] => :environment do |_t, args|
    ImportBTWifiVoucherAllocationsService.new(args[:csv_url]).call
  end
end
