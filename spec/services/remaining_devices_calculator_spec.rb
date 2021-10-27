require 'rails_helper'

RSpec.describe RemainingDevicesCalculator, type: :model do
  subject(:service) { described_class.new }

  let(:devolved_schools) { create_list(:school, 3, :manages_orders, laptops: [1, 0, 0]) }
  let(:managed_schools) { create_list(:school, 3, :centrally_managed, laptops: [1, 0, 0]) }

  describe '#current_unclaimed_totals' do
    before do
      stub_computacenter_outgoing_api_calls
      UpdateSchoolDevicesService.new(school: devolved_schools[0],
                                     order_state: :can_order_for_specific_circumstances,
                                     laptop_allocation: 20,
                                     laptop_cap: 20,
                                     laptops_ordered: 10).call
      UpdateSchoolDevicesService.new(school: devolved_schools[1],
                                     order_state: :can_order_for_specific_circumstances,
                                     laptop_allocation: 30,
                                     laptop_cap: 30,
                                     laptops_ordered: 30).call
      UpdateSchoolDevicesService.new(school: devolved_schools[2],
                                     order_state: :can_order_for_specific_circumstances,
                                     laptop_allocation: 40,
                                     laptop_cap: 20,
                                     laptops_ordered: 5).call

      UpdateSchoolDevicesService.new(school: managed_schools[0],
                                     order_state: :can_order_for_specific_circumstances,
                                     laptop_allocation: 50,
                                     laptop_cap: 50,
                                     laptops_ordered: 10).call
      UpdateSchoolDevicesService.new(school: managed_schools[1],
                                     order_state: :can_order_for_specific_circumstances,
                                     laptop_allocation: 60,
                                     laptop_cap: 60,
                                     laptops_ordered: 60).call
      UpdateSchoolDevicesService.new(school: managed_schools[2],
                                     order_state: :can_order_for_specific_circumstances,
                                     laptop_allocation: 70,
                                     laptop_cap: 40,
                                     laptops_ordered: 15).call
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
