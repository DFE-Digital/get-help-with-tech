FactoryBot.define do
  factory :asset do
    sequence :tag do |n|
      "300#{n}"
    end

    sequence :serial_number do |n|
      "601#{n}"
    end

    model { 'Dell Inspiron' }
    department { 'East Sussex' }
    department_id { 'LEA845' }
    department_sold_to_id { '80160000' }
    location { 'Juniper Street School' }
    location_id { '114000' }
    location_cc_ship_to_account { '81060000' }
    sys_created_at { 1.week.ago }

    # stored as ciphertext in `encrypted_bios_password`
    sequence :bios_password do |n|
      "secretbiospassword#{n}"
    end

    # stored as ciphertext in `encrypted_admin_password`
    sequence :admin_password do |n|
      "secretadminpassword#{n}"
    end

    # stored as ciphertext in `encrypted_hardware_hash`
    sequence :hardware_hash do |n|
      "secrethardwarehash#{n}"
    end

    never_viewed
  end

  trait :school do
    association :school, factory: %i[school]
  end

  trait :responsible_body do
    association :responsible_body, factory: %i[trust]
  end

  trait :never_viewed do
    first_viewed_at { nil }
  end

  trait :viewed do
    first_viewed_at { 1.week.ago }
  end

  trait :lacks_admin_password do
    admin_password { nil }
  end

  trait :lacks_bios_password do
    bios_password { nil }
  end

  trait :lacks_hardware_hash do
    hardware_hash { nil }
  end

  trait :unlockable do
    model { 'Dynabook R50-ec13' }
  end
end
