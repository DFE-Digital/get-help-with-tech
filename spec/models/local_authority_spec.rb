require 'rails_helper'

RSpec.describe LocalAuthority, type: :model do
  subject(:local_authority) { create(:local_authority, address_1: 'Big Office', address_2: 'High St.', town: 'Little Hampton', postcode: 'LH1 2PE') }

  describe '#create_iss_provision!' do
    context 'when a iss provision does not already exist for the LA' do
      it 'adds an iss funded place' do
        expect { local_authority.create_iss_provision! }.to change { LaFundedPlace.count }.by(1)
      end

      it 'creates a provision_urn in the correct format' do
        provision = local_authority.create_iss_provision!
        expect(provision.provision_urn).to eq("ISS#{local_authority.gias_id}")
      end

      it 'populates the address from the local authority' do
        provision = local_authority.create_iss_provision!
        expect(provision.address_1).to eq(local_authority.address_1)
        expect(provision.address_2).to eq(local_authority.address_2)
        expect(provision.town).to eq(local_authority.town)
        expect(provision.postcode).to eq(local_authority.postcode)
      end

      it 'adds preorder information to the provision' do
        provision = local_authority.create_iss_provision!
        expect(provision.orders_managed_by_school?).to be_truthy
      end

      it 'adds a default device and router allocation' do
        provision = local_authority.create_iss_provision!
        expect(provision.std_device_allocation.allocation).to eq(0)
        expect(provision.coms_device_allocation.allocation).to eq(0)
      end

      it 'sets the device and router allocations to the optional supplied values' do
        provision = local_authority.create_iss_provision!(device_allocation: 50, router_allocation: 5)
        expect(provision.std_device_allocation.allocation).to eq(50)
        expect(provision.coms_device_allocation.allocation).to eq(5)
      end
    end

    context 'when a iss provision already exists for the LA' do
      let!(:existing_provision) { create(:iss_provision, responsible_body: local_authority) }

      it 'returns the existing provision' do
        provision = local_authority.create_iss_provision!
        expect(provision).to eq(existing_provision)
      end
    end
  end

  describe '#create_scl_provision!' do
    context 'when a scl provision does not already exist for the LA' do
      it 'adds an scl funded place' do
        expect { local_authority.create_scl_provision! }.to change { LaFundedPlace.count }.by(1)
      end

      it 'creates a provision_urn in the correct format' do
        provision = local_authority.create_scl_provision!
        expect(provision.provision_urn).to eq("SCL#{local_authority.gias_id}")
      end

      it 'populates the address from the local authority' do
        provision = local_authority.create_scl_provision!
        expect(provision.address_1).to eq(local_authority.address_1)
        expect(provision.address_2).to eq(local_authority.address_2)
        expect(provision.town).to eq(local_authority.town)
        expect(provision.postcode).to eq(local_authority.postcode)
      end

      it 'adds preorder information to the provision' do
        provision = local_authority.create_scl_provision!
        expect(provision.orders_managed_by_school?).to be_truthy
      end

      it 'adds a default device and router allocation' do
        provision = local_authority.create_scl_provision!
        expect(provision.std_device_allocation.allocation).to eq(0)
        expect(provision.coms_device_allocation.allocation).to eq(0)
      end

      it 'sets the device and router allocations to the optional supplied values' do
        provision = local_authority.create_scl_provision!(device_allocation: 50, router_allocation: 5)
        expect(provision.std_device_allocation.allocation).to eq(50)
        expect(provision.coms_device_allocation.allocation).to eq(5)
      end
    end

    context 'when a scl provision already exists for the LA' do
      let!(:existing_provision) { create(:scl_provision, responsible_body: local_authority) }

      it 'returns the existing provision' do
        provision = local_authority.create_scl_provision!
        expect(provision).to eq(existing_provision)
      end
    end
  end
end
