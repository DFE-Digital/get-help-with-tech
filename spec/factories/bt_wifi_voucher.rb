FactoryBot.define do
  factory :bt_wifi_voucher do
    username { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
    password { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
  end
end
