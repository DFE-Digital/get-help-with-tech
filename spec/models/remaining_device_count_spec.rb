require 'rails_helper'

RSpec.describe RemainingDeviceCount, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:date_of_count) }
    it { is_expected.to validate_presence_of(:remaining_from_devolved_schools) }
    it { is_expected.to validate_presence_of(:remaining_from_managed_schools) }

    it 'populates the total remaining before validation' do
      rdc = build(:remaining_device_count)
      expect(rdc.total_remaining).to be_nil
      expect(rdc.valid?).to be true
      expect(rdc.total_remaining).to eq(rdc.remaining_from_devolved_schools + rdc.remaining_from_managed_schools)
    end
  end
end
