desc 'Email out assigned BT Wifi vouchers to approved users within responsible bodies'
task email_bt_wifi_vouchers_to_responsible_bodies: :environment do
  EmailVouchersToResponsibleBodiesService.new.call
end
