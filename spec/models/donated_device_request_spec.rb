require 'rails_helper'

RSpec.describe DonatedDeviceRequest, type: :model do
  it { is_expected.to validate_presence_of(:units) }

  it 'validates device_types are correct' do
    request = build(:donated_device_request)
    request.device_types = %w[windows-laptop windows-tablet android-tablet chromebook ipad]
    expect(request.valid?).to be true
    request.device_types << 'biscuit'
    expect(request.valid?).to be false
    expect(request.errors[:device_types]).to be_present
  end
end
