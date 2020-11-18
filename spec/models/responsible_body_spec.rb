require 'rails_helper'

RSpec.describe ResponsibleBody, type: :model do
  subject(:local_authority) { create(:local_authority) }

  describe '#next_school_sorted_ascending_by_name' do
    it 'allows navigating down a list of alphabetically-sorted schools' do
      zebra = create(:school, name: 'Zebra', responsible_body: local_authority)
      aardvark = create(:school, name: 'Aardvark', responsible_body: local_authority)
      tiger = create(:school, name: 'Tiger', responsible_body: local_authority)

      expect(local_authority.next_school_sorted_ascending_by_name(aardvark)).to eq(tiger)
      expect(local_authority.next_school_sorted_ascending_by_name(tiger)).to eq(zebra)
    end
  end

  describe '.convert_computacenter_urn' do
    context 'given a string starting with LEA' do
      it 'returns the same string with LEA removed' do
        expect(ResponsibleBody.convert_computacenter_urn('LEA12345')).to eq('12345')
      end
    end

    context 'given a string starting with t' do
      it 'returns the same string with t removed, padded to 8 chars with leading zeroes' do
        expect(ResponsibleBody.convert_computacenter_urn('t12345')).to eq('00012345')
      end
    end

    context 'given a string starting with SC' do
      it 'returns the same string, untransformed' do
        expect(ResponsibleBody.convert_computacenter_urn('SC12345')).to eq('SC12345')
      end
    end
  end

  describe '.find_by_computacenter_urn!' do
    let!(:trust_with_reference) { create(:trust, companies_house_number: '01234567') }
    let!(:la_with_reference) { create(:local_authority, gias_id: '123') }

    context 'given a string starting with LEA' do
      it 'returns the local authority matched by GIAS id' do
        expect(ResponsibleBody.find_by_computacenter_urn!('LEA123')).to eq(la_with_reference)
      end
    end

    context 'given a string starting with t' do
      it 'returns the trust matched by companies_house_number' do
        expect(ResponsibleBody.find_by_computacenter_urn!('t01234567')).to eq(trust_with_reference)
      end
    end
  end

  describe '#computacenter_identifier' do
    context 'when local authority' do
      subject(:responsible_body) { build(:local_authority) }

      it 'generates correct identifier' do
        expect(responsible_body.computacenter_identifier).to eql("LEA#{responsible_body.gias_id}")
      end
    end

    context 'when trust' do
      subject(:responsible_body) { build(:trust, companies_house_number: '0001') }

      it 'generates correct identifier' do
        expect(responsible_body.computacenter_identifier).to eql('t1')
      end
    end
  end

  describe '#is_ordering_for_schools?' do
    subject(:responsible_body) { create(:trust) }

    let(:schools) { create_list(:school, 2, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }

    context 'when some schools are centrally managed' do
      before do
        schools[0].preorder_information.responsible_body_will_order_devices!
        schools[1].preorder_information.school_will_order_devices!
      end

      it 'returns true' do
        expect(responsible_body.is_ordering_for_schools?).to be true
      end
    end

    context 'when no schools are centrally managed' do
      before do
        schools[0].preorder_information.school_will_order_devices!
        schools[1].preorder_information.school_will_order_devices!
      end

      it 'returns false' do
        expect(responsible_body.is_ordering_for_schools?).to be false
      end
    end
  end

  describe '#has_centrally_managed_schools_that_can_order_now?' do
    subject(:responsible_body) { create(:trust) }

    let(:schools) { create_list(:school, 3, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }

    context 'when some schools are centrally managed' do
      before do
        schools[0].preorder_information.responsible_body_will_order_devices!
        schools[1].preorder_information.responsible_body_will_order_devices!
        schools[2].preorder_information.school_will_order_devices!
      end

      context 'and some managed schools have covid restrictions' do
        before do
          schools[0].can_order!
          schools[2].can_order!
        end

        it 'returns true' do
          expect(responsible_body.has_centrally_managed_schools_that_can_order_now?).to be true
        end
      end

      context 'and no managed schools have covid restrictions' do
        before do
          schools[0].cannot_order!
          schools[2].can_order!
        end

        it 'returns false' do
          expect(responsible_body.has_centrally_managed_schools_that_can_order_now?).to be false
        end
      end
    end

    context 'when no schools are centrally managed' do
      before do
        schools[0].preorder_information.school_will_order_devices!
        schools[1].preorder_information.school_will_order_devices!
        schools[2].preorder_information.school_will_order_devices!
      end

      context 'and no schools have covid restrictions' do
        before do
          schools[0].cannot_order!
          schools[1].cannot_order!
          schools[2].cannot_order!
        end

        it 'returns false' do
          expect(responsible_body.has_centrally_managed_schools_that_can_order_now?).to be false
        end
      end

      context 'and some devolved schools have covid restrictions' do
        before do
          schools[0].cannot_order!
          schools[1].can_order_for_specific_circumstances!
          schools[2].can_order!
        end

        it 'returns false' do
          expect(responsible_body.has_centrally_managed_schools_that_can_order_now?).to be false
        end
      end
    end
  end

  describe '#has_schools_that_can_order_devices_now?' do
    subject(:responsible_body) { create(:trust) }

    let(:schools) { create_list(:school, 3, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }

    context 'when some schools that will order are able to order devices' do
      before do
        schools[0].preorder_information.responsible_body_will_order_devices!
        schools[1].preorder_information.school_will_order_devices!
        schools[2].preorder_information.school_will_order_devices!
        schools[0].can_order!
        schools[1].cannot_order!
        schools[2].can_order_for_specific_circumstances!
      end

      it 'returns true' do
        expect(responsible_body.has_schools_that_can_order_devices_now?).to be true
      end
    end

    context 'when no schools that will order are able to order devices' do
      before do
        schools[0].preorder_information.responsible_body_will_order_devices!
        schools[1].preorder_information.school_will_order_devices!
        schools[2].preorder_information.school_will_order_devices!
        schools[0].can_order!
        schools[1].cannot_order!
        schools[2].cannot_order!
      end

      it 'returns false' do
        expect(responsible_body.has_schools_that_can_order_devices_now?).to be false
      end
    end
  end

  describe '#has_any_schools_that_can_order_now?' do
    subject(:responsible_body) { create(:trust) }

    let(:schools) { create_list(:school, 3, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }

    context 'when some centrally managed schools are able to order devices' do
      before do
        schools[0].preorder_information.responsible_body_will_order_devices!
        schools[1].preorder_information.school_will_order_devices!
        schools[2].preorder_information.school_will_order_devices!
        schools[0].can_order!
        schools[1].cannot_order!
        schools[2].cannot_order!
      end

      it 'returns true' do
        expect(responsible_body.has_any_schools_that_can_order_now?).to be true
      end
    end

    context 'when some devolved schools are able to order devices' do
      before do
        schools[0].preorder_information.responsible_body_will_order_devices!
        schools[1].preorder_information.school_will_order_devices!
        schools[2].preorder_information.school_will_order_devices!
        schools[0].cannot_order!
        schools[1].cannot_order!
        schools[2].can_order_for_specific_circumstances!
      end

      it 'returns true' do
        expect(responsible_body.has_any_schools_that_can_order_now?).to be true
      end
    end

    context 'when none of the RBs schools are able to order devices' do
      before do
        schools[0].preorder_information.responsible_body_will_order_devices!
        schools[1].preorder_information.school_will_order_devices!
        schools[2].preorder_information.school_will_order_devices!
        schools[0].cannot_order!
        schools[1].cannot_order!
        schools[2].cannot_order!
      end

      it 'returns false' do
        expect(responsible_body.has_any_schools_that_can_order_now?).to be false
      end
    end
  end

  describe '#add_school_to_virtual_cap_pools' do
    subject(:responsible_body) { create(:trust, :manages_centrally) }

    let(:schools) { create_list(:school, 3, :with_std_device_allocation, :with_coms_device_allocation, :with_preorder_information, :in_lockdown, responsible_body: responsible_body) }

    before do
      schools.each do |s|
        s.std_device_allocation.update!(allocation: 10, cap: 10, devices_ordered: 2)
        s.coms_device_allocation.update!(allocation: 20, cap: 5, devices_ordered: 3)
      end
    end

    it 'adds the schools cap and devices_ordered to the relevant pool' do
      schools.each { |s| responsible_body.add_school_to_virtual_cap_pools!(s) }
      responsible_body.reload
      expect(responsible_body.std_device_pool.cap).to eq(30)
      expect(responsible_body.std_device_pool.devices_ordered).to eq(6)
      expect(responsible_body.coms_device_pool.cap).to eq(15)
      expect(responsible_body.coms_device_pool.devices_ordered).to eq(9)
    end

    it 'creates the virtual pool for the device type if it does not exists' do
      expect { responsible_body.add_school_to_virtual_cap_pools!(schools.first) }.to change { VirtualCapPool.count }.by(2)
      expect { responsible_body.add_school_to_virtual_cap_pools!(schools.second) }.not_to(change { VirtualCapPool.count })
    end
  end

  describe '#calculate_virtual_caps!' do
    subject(:responsible_body) { create(:trust, :manages_centrally) }

    let(:schools) { create_list(:school, 3, :with_std_device_allocation, :with_coms_device_allocation, :with_preorder_information, :in_lockdown, responsible_body: responsible_body) }

    before do
      schools.each do |s|
        s.std_device_allocation.update!(allocation: 10, cap: 10, devices_ordered: 2)
        s.coms_device_allocation.update!(allocation: 20, cap: 5, devices_ordered: 3)
        responsible_body.add_school_to_virtual_cap_pools!(s)
      end
    end

    it 'calculates the virtual cap for all device types' do
      schools.first.std_device_allocation.update!(cap: 100, allocation: 100, devices_ordered: 75)
      schools.last.coms_device_allocation.update!(cap: 50, allocation: 100, devices_ordered: 25)

      responsible_body.calculate_virtual_caps!
      expect(responsible_body.std_device_pool.cap).to eq(120)
      expect(responsible_body.std_device_pool.devices_ordered).to eq(79)
      expect(responsible_body.coms_device_pool.cap).to eq(60)
      expect(responsible_body.coms_device_pool.devices_ordered).to eq(31)
    end
  end
end
