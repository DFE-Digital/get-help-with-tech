class AddIqMobileToMobileNetworks < ActiveRecord::Migration[6.1]
  def up
    iq_mobile = MobileNetwork.find_by_brand('IQ Mobile') || MobileNetwork.create(brand: 'IQ Mobile', host_network: 'EE', participation_in_pilot: 'yes')
  end

  def down
    MobileNetwork.find_by_brand('IQ Mobile')&.update(participation_in_pilot: 'no')
  end
end
