namespace :import do
  desc 'Import BT Wifi vouchers'
  task :bt_wifi_vouchers, [:csv_url] => :environment do
    ImportBTWifiVouchersService.new(csv_url).call
  end
end
