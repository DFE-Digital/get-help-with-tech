namespace :bt_wifi do
  desc 'Import BT Wifi vouchers'
  task :import_vouchers, [:csv_url] => :environment do |_t, args|
    ImportBTWifiVouchersService.new(args[:csv_url]).call
  end

  desc 'Import BT Wifi voucher allocations'
  task :import_voucher_allocations, [:csv_url] => :environment do |_t, args|
    ImportBTWifiVoucherAllocationsService.new(args[:csv_url]).call
  end

  desc 'Assign BT Wifi vouchers to responsible bodies with allocations'
  task assign_vouchers_to_responsible_bodies: :environment do
    AssignBTWifiVouchersToResponsibleBodiesService.new.call
  end
end
