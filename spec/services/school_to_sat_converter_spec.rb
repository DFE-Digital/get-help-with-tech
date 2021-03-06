require 'rails_helper'

RSpec.describe SchoolToSatConverter, type: :model do
  let(:local_authority) { create(:local_authority, name: 'Camden') }
  let(:school) { create(:school, urn: '103001', responsible_body: local_authority) }

  subject(:converter) { described_class.new(school) }

  context 'no company info available for the school' do
    it 'creates a Trust with the Schools name and no companies house number' do
      expect { converter.convert_to_sat }.to change { Trust.count }.by(1)
      trust = Trust.last
      expect(trust.name).to eq(school.name)
      expect(trust.companies_house_number).to be_blank
      expect(trust.organisation_type).to eq('single_academy_trust')
      expect(trust.who_will_order_devices).to eq('school')
      expect(trust.address_1).to eq(school.address_1)
      expect(trust.address_2).to eq(school.address_2)
      expect(trust.address_3).to eq(school.address_3)
      expect(trust.town).to eq(school.town)
      expect(trust.county).to eq(school.county)
      expect(trust.postcode).to eq(school.postcode)

      school.reload
      expect(school.preorder_information.who_will_order_devices).to eq('school')
      expect(school.std_device_allocation.allocation).to eq(0)
    end
  end

  context 'when a trust name is available but no companies house number' do
    let(:trust_name) { 'THE NEW TRUST' }

    it 'creates a Trust with the specified name and no companies house number' do
      expect { converter.convert_to_sat(trust_name: trust_name) }.to change { Trust.count }.by(1)
      trust = Trust.last
      expect(trust.name).to eq(trust_name)
      expect(trust.companies_house_number).to be_blank
      expect(trust.organisation_type).to eq('single_academy_trust')
      expect(trust.who_will_order_devices).to eq('school')
      school.reload
      expect(school.preorder_information.who_will_order_devices).to eq('school')
      expect(school.std_device_allocation.allocation).to eq(0)
    end
  end

  context 'when a trust name and companies house number are supplied' do
    let(:trust_name) { 'THE NEW TRUST' }
    let(:companies_house_number) { '01231234' }

    it 'creates a Trust with the specified name and companies house number' do
      expect {
        converter.convert_to_sat(trust_name: trust_name,
                                 companies_house_number: companies_house_number)
      }.to change { Trust.count }.by(1)

      trust = Trust.last
      expect(trust.name).to eq(trust_name)
      expect(trust.companies_house_number).to eq(companies_house_number)
      expect(trust.organisation_type).to eq('single_academy_trust')
      expect(trust.who_will_order_devices).to eq('school')
      school.reload
      expect(school.preorder_information.who_will_order_devices).to eq('school')
      expect(school.std_device_allocation.allocation).to eq(0)
    end
  end

  context 'when the school has a device allocation' do
    it 'does not alter the allocation' do
      school.device_allocations.create!(device_type: 'std_device', allocation: 20)

      converter.convert_to_sat
      school.reload
      expect(school.std_device_allocation.allocation).to eq(20)
    end
  end

  context 'when the school has preorder information and was centrally managed' do
    it 'updates the preorder information so the school will order devices' do
      school.create_preorder_information!(who_will_order_devices: 'responsible_body')

      converter.convert_to_sat

      school.reload
      expect(school.preorder_information.who_will_order_devices).to eq('school')
    end
  end
end
