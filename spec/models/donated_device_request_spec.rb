require 'rails_helper'

RSpec.describe DonatedDeviceRequest, type: :model do
  it 'validates device_types are correct' do
    school = create(:school)
    request = build(:donated_device_request, schools: [school.id])
    request.device_types = %w[windows android-tablet chromebook ipad]
    expect(request.valid?).to be true
    request.device_types << 'biscuit'
    expect(request.valid?).to be false
    expect(request.errors[:device_types]).to be_present
  end

  it 'validates units are present when the status is units-step or complete' do
    school = create(:school)
    request = build(:donated_device_request, :wants_laptops, schools: [school.id], units: nil)
    expect(request.valid?).to be true
    request.status = 'units_step'
    expect(request.valid?).to be false
    expect(request.errors[:units]).to be_present
    request.status = 'incomplete'
    expect(request.valid?).to be true
    request.status = 'complete'
    expect(request.valid?).to be false
    expect(request.errors[:units]).to be_present
  end
end
