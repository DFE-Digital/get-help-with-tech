require 'rails_helper'

RSpec.describe ResponsibleBody, type: :model do
  subject(:responsible_body) { create(:local_authority) }

  describe '#active_schools' do
    let!(:schools) { create(:school, responsible_body: responsible_body) }
    let(:closed_schools) { create(:school, status: 'closed', responsible_body: responsible_body) }
    let(:la_funded_place) { create(:iss_provision, responsible_body: responsible_body) }

    before do
      closed_schools
      la_funded_place
    end

    it 'returns my list of schools' do
      expect(responsible_body.active_schools).to match_array(schools)
    end
  end

  describe '#next_school_sorted_ascending_by_name' do
    it 'allows navigating down a list of alphabetically-sorted schools' do
      zebra = create(:school, name: 'Zebra', responsible_body: responsible_body)
      aardvark = create(:school, name: 'Aardvark', responsible_body: responsible_body)
      tiger = create(:school, name: 'Tiger', responsible_body: responsible_body)

      expect(responsible_body.next_school_sorted_ascending_by_name(aardvark)).to eq(tiger)
      expect(responsible_body.next_school_sorted_ascending_by_name(tiger)).to eq(zebra)
    end

    it 'does not include LaFundedPlaces' do
      zebra = create(:school, name: 'Zebra', responsible_body: responsible_body)
      aardvark = create(:school, name: 'Aardvark', responsible_body: responsible_body)
      tiger = create(:school, name: 'Tiger', responsible_body: responsible_body)
      create(:iss_provision, responsible_body: responsible_body, name: 'Snake')

      expect(responsible_body.next_school_sorted_ascending_by_name(aardvark)).to eq(tiger)
      expect(responsible_body.next_school_sorted_ascending_by_name(tiger)).to eq(zebra)
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
    let(:schools) { create_list(:school, 3, :with_std_device_allocation, :centrally_managed, responsible_body: responsible_body) }

    context 'when some schools are centrally managed' do
      before do
        schools[1].orders_managed_by_school!
        schools[2].update!(status: :closed)
      end

      it 'returns true' do
        expect(responsible_body.is_ordering_for_schools?).to be true
      end
    end

    context 'when no schools are centrally managed' do
      before do
        schools[0].orders_managed_by_school!
        schools[1].orders_managed_by_school!
        schools[2].update!(status: :closed)
      end

      it 'returns false' do
        expect(responsible_body.is_ordering_for_schools?).to be false
      end
    end
  end

  describe '#has_centrally_managed_schools_that_can_order_now?' do
    let(:schools) { create_list(:school, 4, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }

    context 'when some schools are centrally managed' do
      before do
        schools[0].orders_managed_centrally!
        schools[1].orders_managed_centrally!
        schools[2].orders_managed_by_school!
        schools[3].update!(status: :closed)
      end

      context 'and some managed schools have covid restrictions' do
        before do
          schools[0].can_order!
          schools[2].can_order!
          schools[3].update!(status: :closed)
        end

        it 'returns true' do
          expect(responsible_body.has_centrally_managed_schools_that_can_order_now?).to be true
        end
      end

      context 'and no managed schools have covid restrictions' do
        before do
          schools[0].cannot_order!
          schools[2].can_order!
          schools[3].update!(status: :closed)
        end

        it 'returns false' do
          expect(responsible_body.has_centrally_managed_schools_that_can_order_now?).to be false
        end
      end

      context 'when LA funded places are present' do
        let(:la_funded_place) { create(:iss_provision, :centrally_managed, :with_std_device_allocation, responsible_body: responsible_body) }

        before do
          schools.each(&:cannot_order!)
          la_funded_place.can_order!
        end

        it 'does not include the LA funded place' do
          expect(responsible_body).not_to have_centrally_managed_schools_that_can_order_now
        end
      end
    end

    context 'when no schools are centrally managed' do
      before do
        schools[0].orders_managed_by_school!
        schools[1].orders_managed_by_school!
        schools[2].orders_managed_by_school!
        schools[3].update!(status: :closed)
      end

      context 'and no schools have covid restrictions' do
        before do
          schools[0].cannot_order!
          schools[1].cannot_order!
          schools[2].cannot_order!
          schools[3].update!(status: :closed)
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
          schools[3].update!(status: :closed)
        end

        it 'returns false' do
          expect(responsible_body.has_centrally_managed_schools_that_can_order_now?).to be false
        end
      end

      context 'when LA funded places are present' do
        let(:la_funded_place) { create(:iss_provision, :manages_orders, :with_std_device_allocation, responsible_body: responsible_body) }

        before do
          schools.each(&:cannot_order!)
          la_funded_place.can_order!
        end

        it 'does not include the LA funded place' do
          expect(responsible_body).not_to have_centrally_managed_schools_that_can_order_now
        end
      end
    end
  end

  describe '#has_centrally_managed_schools?' do
    subject(:responsible_body) { create(:trust) }

    let(:schools) { create_list(:school, 4, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }

    context 'when some schools are centrally managed' do
      before do
        schools[0].orders_managed_centrally!
        schools[1].orders_managed_centrally!
        schools[2].orders_managed_by_school!
        schools[3].update!(status: :closed)
      end

      it 'returns true' do
        expect(responsible_body.has_centrally_managed_schools?).to be true
      end
    end

    context 'when no schools are centrally managed' do
      before do
        schools[0].orders_managed_by_school!
        schools[1].orders_managed_by_school!
        schools[2].orders_managed_by_school!
        schools[3].update!(status: :closed)
      end

      it 'returns false' do
        expect(responsible_body.has_centrally_managed_schools?).to be false
      end
    end
  end

  describe '#has_schools_that_can_order_devices_now?' do
    let(:schools) { create_list(:school, 4, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }

    context 'when some schools that will order are able to order devices' do
      before do
        schools[0].orders_managed_centrally!
        schools[1].orders_managed_by_school!
        schools[2].orders_managed_by_school!
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
        schools[0].orders_managed_centrally!
        schools[1].orders_managed_by_school!
        schools[2].orders_managed_by_school!
        schools[0].can_order!
        schools[1].cannot_order!
        schools[2].cannot_order!
        schools[3].update!(status: :closed)
      end

      it 'returns false' do
        expect(responsible_body.has_schools_that_can_order_devices_now?).to be false
      end

      context 'when LA funded places are present' do
        let(:la_funded_place) { create(:iss_provision, :manages_orders, :with_std_device_allocation, responsible_body: responsible_body) }

        before do
          la_funded_place.can_order!
        end

        it 'does not include the LA funded place' do
          expect(responsible_body).not_to have_schools_that_can_order_devices_now
        end
      end
    end
  end

  describe '#has_any_schools_that_can_order_now?' do
    let(:schools) { create_list(:school, 4, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }

    context 'when some centrally managed schools are able to order devices' do
      before do
        schools[0].orders_managed_centrally!
        schools[1].orders_managed_by_school!
        schools[2].orders_managed_by_school!
        schools[0].can_order!
        schools[1].cannot_order!
        schools[2].cannot_order!
        schools[3].update!(status: :closed)
      end

      it 'returns true' do
        expect(responsible_body.has_any_schools_that_can_order_now?).to be true
      end
    end

    context 'when some devolved schools are able to order devices' do
      before do
        schools[0].orders_managed_centrally!
        schools[1].orders_managed_by_school!
        schools[2].orders_managed_by_school!
        schools[0].cannot_order!
        schools[1].cannot_order!
        schools[2].can_order_for_specific_circumstances!
        schools[3].update!(status: :closed)
      end

      it 'returns true' do
        expect(responsible_body.has_any_schools_that_can_order_now?).to be true
      end
    end

    context 'when none of the RBs schools are able to order devices' do
      before do
        schools[0].orders_managed_centrally!
        schools[1].orders_managed_by_school!
        schools[2].orders_managed_by_school!
        schools[0].cannot_order!
        schools[1].cannot_order!
        schools[2].cannot_order!
        schools[3].update!(status: :closed)
      end

      it 'returns false' do
        expect(responsible_body.has_any_schools_that_can_order_now?).to be false
      end
    end

    context 'when LA funded places are present' do
      let(:la_funded_place) { create(:iss_provision, :manages_orders, :with_std_device_allocation, responsible_body: responsible_body) }

      before do
        schools.each(&:cannot_order!)
        la_funded_place.can_order!
      end

      it 'does not include the LA funded place' do
        expect(responsible_body).not_to have_any_schools_that_can_order_now
      end
    end
  end

  describe '#calculate_virtual_caps!' do
    subject(:responsible_body) { create(:trust, :manages_centrally, vcap_feature_flag: true) }

    let(:schools) { create_list(:school, 3, :with_std_device_allocation, :with_coms_device_allocation, :centrally_managed, :in_lockdown, responsible_body: responsible_body) }

    before do
      stub_computacenter_outgoing_api_calls
      schools.each do |s|
        s.std_device_allocation.update!(allocation: 10, cap: 10, devices_ordered: 2)
        s.coms_device_allocation.update!(allocation: 20, cap: 5, devices_ordered: 3)
        AddSchoolToVirtualCapPoolService.new(s).call
      end
      responsible_body.reload
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

  describe '#has_school_in_virtual_cap_pools?' do
    subject(:responsible_body) { create(:trust, :manages_centrally, vcap_feature_flag: true) }

    let(:schools) { create_list(:school, 2, :with_std_device_allocation, :with_coms_device_allocation, :centrally_managed, :in_lockdown, responsible_body: responsible_body) }

    before do
      stub_computacenter_outgoing_api_calls
      first_school = schools.first
      first_school.std_device_allocation.update!(allocation: 10, cap: 10, devices_ordered: 2)
      first_school.coms_device_allocation.update!(allocation: 20, cap: 5, devices_ordered: 3)
      AddSchoolToVirtualCapPoolService.new(first_school).call
      responsible_body.reload
    end

    it 'returns true for a school within the pool' do
      expect(responsible_body.has_school_in_virtual_cap_pools?(schools.first)).to be true
    end

    it 'returns false for a school outside the pool' do
      expect(responsible_body.has_school_in_virtual_cap_pools?(schools.last)).to be false
    end
  end

  describe '#devices_available_to_order?' do
    subject(:responsible_body) { create(:trust, :manages_centrally, vcap_feature_flag: true) }

    let(:schools) { create_list(:school, 2, :with_std_device_allocation, :with_coms_device_allocation, :centrally_managed, :in_lockdown, responsible_body: responsible_body) }

    before do
      stub_computacenter_outgoing_api_calls
      schools.each do |s|
        AddSchoolToVirtualCapPoolService.new(s).call
      end
      responsible_body.reload
    end

    context 'when used full allocation' do
      before do
        schools.first.std_device_allocation.update!(cap: 100, allocation: 100, devices_ordered: 100)
        schools.last.coms_device_allocation.update!(cap: 50, allocation: 100, devices_ordered: 100)

        responsible_body.calculate_virtual_caps!
      end

      it 'returns false' do
        expect(responsible_body.devices_available_to_order?).to be false
      end
    end

    context 'when partially used allocation' do
      before do
        schools.first.std_device_allocation.update!(cap: 100, allocation: 100, devices_ordered: 75)
        schools.last.coms_device_allocation.update!(cap: 50, allocation: 100, devices_ordered: 100)

        responsible_body.calculate_virtual_caps!
      end

      it 'returns true' do
        expect(responsible_body.devices_available_to_order?).to be true
      end
    end

    context 'when no devices ordered' do
      before do
        schools.first.std_device_allocation.update!(cap: 100, allocation: 100, devices_ordered: 0)
        schools.last.coms_device_allocation.update!(cap: 50, allocation: 100, devices_ordered: 0)

        responsible_body.calculate_virtual_caps!
      end

      it 'returns true' do
        expect(responsible_body.devices_available_to_order?).to be true
      end
    end
  end

  describe '#has_virtual_cap_feature_flags?' do
    subject(:responsible_body) { create(:trust, :manages_centrally) }

    context 'without any feature flags' do
      before do
        responsible_body.update!(vcap_feature_flag: false)
      end

      it 'returns false' do
        expect(responsible_body.has_virtual_cap_feature_flags?).to be false
      end
    end

    context 'when responsible body flag is enabled' do
      before do
        responsible_body.update!(vcap_feature_flag: true)
      end

      it 'returns true' do
        expect(responsible_body.has_virtual_cap_feature_flags?).to be true
      end
    end
  end

  describe '#has_virtual_cap_feature_flags_and_centrally_managed_schools?' do
    subject(:responsible_body) { create(:trust) }

    let(:schools) { create_list(:school, 4, :with_std_device_allocation, :centrally_managed, responsible_body: responsible_body) }

    context 'when some schools are centrally managed' do
      before do
        schools[2].orders_managed_by_school!
        schools[3].update!(status: :closed)
      end

      context 'without any feature flags' do
        before do
          responsible_body.update!(vcap_feature_flag: false)
        end

        it 'returns false' do
          expect(responsible_body.has_virtual_cap_feature_flags_and_centrally_managed_schools?).to be false
        end
      end

      context 'when responsible body flag is enabled' do
        before do
          responsible_body.update!(vcap_feature_flag: true)
        end

        it 'returns true' do
          expect(responsible_body.has_virtual_cap_feature_flags_and_centrally_managed_schools?).to be true
        end
      end
    end

    context 'when no schools are centrally managed' do
      before do
        schools[0].orders_managed_by_school!
        schools[1].orders_managed_by_school!
        schools[2].orders_managed_by_school!
        schools[3].update!(status: :closed)
      end

      context 'without any feature flags' do
        before do
          responsible_body.update!(vcap_feature_flag: false)
        end

        it 'returns false' do
          expect(responsible_body.has_virtual_cap_feature_flags_and_centrally_managed_schools?).to be false
        end
      end

      context 'when responsible body flag is enabled' do
        before do
          responsible_body.update!(vcap_feature_flag: true)
        end

        it 'returns false' do
          expect(responsible_body.has_virtual_cap_feature_flags_and_centrally_managed_schools?).to be false
        end
      end
    end
  end

  describe '.managing_multiple_chromebook_domains' do
    subject(:responsible_body) { create(:trust, :manages_centrally) }

    let(:second_rb) { create(:trust, :manages_centrally) }
    let(:third_rb) { create(:trust, :devolves_management) }

    let(:schools) { create_list(:school, 2, :with_std_device_allocation, :centrally_managed, responsible_body: responsible_body) }
    let(:second_schools) { create_list(:school, 2, :with_std_device_allocation, :centrally_managed, responsible_body: second_rb) }
    let(:third_schools) { create_list(:school, 2, :with_std_device_allocation, :centrally_managed, responsible_body: third_rb) }

    before do
      third_schools[0].orders_managed_by_school!
      third_schools[1].orders_managed_by_school!
    end

    context 'when centrally managed schools have different chromebook domains within a responsible body' do
      before do
        schools[0].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school0.google.com')
        schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school1.google.com')
        second_schools[0].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                                    school_or_rb_domain: 'school0.google2.com')
        second_schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                                    school_or_rb_domain: 'school1.google2.com')
      end

      it 'returns the responsible bodies that manage those schools' do
        result = described_class.managing_multiple_chromebook_domains
        expect(result).to match_array [responsible_body, second_rb]
      end
    end

    context 'when a closed school has a different chromebook domain' do
      before do
        schools[0].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school.google.com')
        schools[1].gias_status_closed!
        schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school4.google.com')
        second_schools[0].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                                    school_or_rb_domain: 'school0.google2.com')
        second_schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                                    school_or_rb_domain: 'school1.google2.com')
      end

      it 'does not count closed schools when determining the domains' do
        result = described_class.managing_multiple_chromebook_domains
        expect(result).to include second_rb
        expect(result).not_to include responsible_body
      end
    end

    context 'it does not consider schools that are not centrally managed' do
      before do
        schools[0].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school0.google.com')
        schools[1].orders_managed_by_school!
        schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school1.google.com')
        third_schools[0].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                                   school_or_rb_domain: 'school0.google3.com')
        third_schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                                   school_or_rb_domain: 'school1.google3.com')
      end

      it 'does not count closed schools when determining the domains' do
        result = described_class.managing_multiple_chromebook_domains
        expect(result).to be_empty
      end
    end
  end

  describe '#has_multiple_chromebook_domains_in_managed_schools?' do
    subject(:responsible_body) { create(:trust, :manages_centrally) }

    let(:schools) { create_list(:school, 2, :with_std_device_allocation, :centrally_managed, responsible_body: responsible_body) }

    context 'when centrally managed schools have different chromebook domains' do
      before do
        schools[0].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school0.google.com')
        schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school1.google.com')
      end

      it 'returns true' do
        expect(responsible_body.has_multiple_chromebook_domains_in_managed_schools?).to be true
      end
    end

    context 'it does not consider closed schools' do
      before do
        schools[0].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school.google.com')
        schools[1].gias_status_closed!
        schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school4.google.com')
      end

      it 'returns false' do
        expect(responsible_body.has_multiple_chromebook_domains_in_managed_schools?).to be false
      end
    end

    context 'it does not consider schools that are not centrally managed' do
      before do
        schools[0].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school0.google.com')
        schools[1].orders_managed_by_school!
        schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school1.google.com')
      end

      it 'returns false' do
        expect(responsible_body.has_multiple_chromebook_domains_in_managed_schools?).to be false
      end
    end
  end
end
