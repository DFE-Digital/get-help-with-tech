require 'rails_helper'

RSpec.describe RemainingDevicesCalculator, type: :model do
  subject(:service) { described_class.new }

  let(:devolved_schools) { create_list(:school, 3, :manages_orders, :with_std_device_allocation) }
  let(:managed_schools) { create_list(:school, 3, :centrally_managed, :with_std_device_allocation) }

  describe '#current_unclaimed_totals' do
    before do
      devolved_schools[0].std_device_allocation.update!(allocation: 20, cap: 20, devices_ordered: 10)
      devolved_schools[1].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 30)
      devolved_schools[2].std_device_allocation.update!(allocation: 40, cap: 20, devices_ordered: 5)
      managed_schools[0].std_device_allocation.update!(allocation: 50, cap: 50, devices_ordered: 10)
      managed_schools[1].std_device_allocation.update!(allocation: 60, cap: 60, devices_ordered: 60)
      managed_schools[2].std_device_allocation.update!(allocation: 70, cap: 40, devices_ordered: 15)
    end

    it 'returns a RemainingDeviceCount object with the current totals remaining' do
      rdc = service.current_unclaimed_totals
      expect(rdc.remaining_from_devolved_schools).to eq(70 - 45) #  = 25
      expect(rdc.remaining_from_managed_schools).to eq(150 - 85) #  = 65
      expect(rdc.total_remaining).to eq(25 + 65)
    end

    it 'returns a RemainingDeviceCount object for the current datetime' do
      rdc = service.current_unclaimed_totals
      expect(rdc.date_of_count).to be_within(2.seconds).of(Time.zone.now)
    end

    it 'returns a RemainingDeviceCount object that has not been persisted' do
      rdc = service.current_unclaimed_totals
      expect(rdc.persisted?).to be false
    end
  end
end
