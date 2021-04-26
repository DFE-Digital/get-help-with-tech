require 'rails_helper'

RSpec.describe LocalAuthority do
  subject(:la) { create(:local_authority) }

  describe '#create_social_care_provision!' do
    it 'creates a new school record' do
      expect {
        la.create_social_care_provision!(urn: 123_456, device_allocation: 10, router_allocation: 20)
      }.to change(School, :count).by(1)

      record = la.reload.social_care_provision
      expect(record.urn).to be(123_456)
      expect(record.name).to eql('Care leavers')
      expect(record.address_1).to eql(la.address_1)
      expect(record.address_2).to eql(la.address_2)
      expect(record.address_3).to eql(la.address_3)
      expect(record.town).to eql(la.town)
      expect(record.county).to eql(la.county)
      expect(record.postcode).to eql(la.postcode)
    end

    it 'creates a preorder' do
      expect {
        la.create_social_care_provision!(urn: 123_456, device_allocation: 10, router_allocation: 20)
      }.to change { PreorderInformation.count }.by(1)

      record = PreorderInformation.last
      expect(record.who_will_order_devices).to eql('school')
    end

    it 'creates a new device allocation' do
      expect {
        la.create_social_care_provision!(urn: 123_456, device_allocation: 10, router_allocation: 20)
      }.to change { SchoolDeviceAllocation.std_device.count }.by(1)

      record = SchoolDeviceAllocation.std_device.last
      expect(record.allocation).to be(10)
    end

    it 'creates a new router allocation' do
      expect {
        la.create_social_care_provision!(urn: 123_456, device_allocation: 10, router_allocation: 20)
      }.to change { SchoolDeviceAllocation.coms_device.count }.by(1)

      record = SchoolDeviceAllocation.coms_device.last
      expect(record.allocation).to be(20)
    end
  end
end
