require 'rails_helper'

RSpec.describe SchoolUpdateService, type: :model do
  subject(:service) { described_class.new }

  describe 'importing schools from staging' do
    let!(:local_authority) { create(:local_authority, name: 'Camden') }
    let!(:school) { create(:school, urn: '103001', responsible_body: local_authority) }

    context 'data update timestamps' do
      it 'updates the DataUpdateRecord timestamp for schools' do
        t = Time.zone.now
        Timecop.freeze(t) do
          service.update_schools
          expect(DataStage::DataUpdateRecord.last_update_for(:schools)).to be_within(1.second).of(t)
        end
      end

      it 'only applies changes since the last update' do
        Timecop.travel(6.hours.ago)
        create(:staged_school, urn: 103_001, responsible_body_name: 'Camden')
        Timecop.return

        Timecop.travel(2.hours.ago)
        DataStage::DataUpdateRecord.updated!(:schools)
        Timecop.return

        school_attrs = school.attributes.symbolize_keys

        service.update_schools
        expect(school.reload).to have_attributes(
          urn: school_attrs[:urn],
          name: school_attrs[:name],
          responsible_body_id: local_authority.id,
          address_1: school_attrs[:address_1],
          address_2: school_attrs[:address_2],
          address_3: school_attrs[:address_3],
          town: school_attrs[:town],
          postcode: school_attrs[:postcode],
          phase: school_attrs[:phase],
          establishment_type: school_attrs[:establishment_type],
          status: school_attrs[:status],
        )
      end
    end

    context 'when a school already exists' do
      let!(:staged_school) { create(:staged_school, urn: 103_001, responsible_body_name: 'Camden') }

      it 'updates the existing school record' do
        service.update_schools

        expect(school.reload).to have_attributes(
          urn: 103_001,
          name: staged_school.name,
          responsible_body_id: local_authority.id,
          address_1: staged_school.address_1,
          address_2: staged_school.address_2,
          address_3: staged_school.address_3,
          town: staged_school.town,
          postcode: staged_school.postcode,
          phase: staged_school.phase,
          establishment_type: staged_school.establishment_type,
          status: staged_school.status,
        )
      end
    end
  end

  describe '#create_school!' do
    let!(:staged_school) { create(:staged_school, urn: 103_001, responsible_body_name: 'Camden') }
    let!(:local_authority) { create(:local_authority, name: 'Camden') }

    it 'creates school record' do
      expect {
        service.create_school!(staged_school)
      }.to change(School, :count).by(1)
    end

    context 'when the responsible body name has to be mapped' do
      let!(:mapped_la) { create(:local_authority, name: 'City of Bristol') }

      before do
        staged_school.update!(responsible_body_name: 'Bristol, City of')
      end

      it 'looks up the name to find the correct responsible body' do
        school = service.create_school!(staged_school)
        expect(school.responsible_body).to eq(mapped_la)
      end
    end

    context 'when the responsible body has decided who will order' do
      before do
        local_authority.update!(who_will_order_devices: 'schools')
      end

      it 'sets up ordering information' do
        school = service.create_school!(staged_school)
        expect(school.preorder_status).to be_present
      end
    end
    #
    # context 'when the responsible body has not decided who will order' do
    #   before do
    #     local_authority.update!(who_will_order_devices: nil)
    #   end
    #
    #   it 'does not set up ordering information' do
    #     school = service.create_school!(staged_school)
    #     expect(school.preorder_status).not_to be_present
    #   end
    # end

    context 'when there is an existing predecessor school' do
      let(:old_staged_school) { create(:staged_school, urn: 100_001, responsible_body_name: 'Camden', status: 'closed') }
      let!(:old_school) { create(:school, :with_preorder_information, laptops: [1, 0, 0], routers: [1, 0, 0], name: old_staged_school.name, urn: old_staged_school.urn, responsible_body: local_authority) }
      let(:old_school_link) { create(:staged_school_link, staged_school: old_staged_school, link_urn: staged_school.urn) }
      let(:school_link) { create(:staged_school_link, :predecessor, staged_school: staged_school, link_urn: old_staged_school.urn) }
      let!(:users) { create_list(:school_user, 2, school: old_school) }

      before do
        school_link
        old_school_link
        old_school.update!(raw_laptop_allocation: 100, raw_laptop_cap: 100, raw_laptops_ordered: 90)
        old_school.update!(raw_router_allocation: 10, raw_router_cap: 10, raw_routers_ordered: 8)
      end

      it 'closes the predecessor school' do
        service.create_school!(staged_school)
        expect(old_school.reload.status).to eq('closed')
      end

      it 'transfers any spare allocations from the predecessor and adjusts original values' do
        school = service.create_school!(staged_school)
        old_school.reload
        expect(school.raw_allocation(:laptop)).to eq(10)
        expect(school.raw_allocation(:router)).to eq(2)
        expect(old_school.raw_allocation(:laptop)).to eq(90)
        expect(old_school.raw_cap(:laptop)).to eq(90)
        expect(old_school.raw_allocation(:router)).to eq(8)
        expect(old_school.raw_cap(:router)).to eq(8)
      end

      it 'moves users from the predecessor to the new school' do
        school = service.create_school!(staged_school)
        old_school.reload
        expect(school.users).to match_array(users)
        expect(old_school.users).to be_empty
      end

      it 'creates school_links on new school' do
        school = service.create_school!(staged_school)
        expect(school.school_links.count).to be(1)
      end

      it 'creates school_links on old school' do
        service.create_school!(staged_school)
        old_school.reload
        expect(old_school.school_links.count).to be(1)
      end

      context 'when the predecessor is in a virtual cap pool' do
        let(:response) { OpenStruct.new(body: '<xml>test-response</xml>') }

        before do
          stub_computacenter_outgoing_api_calls

          rb = old_school.responsible_body
          rb.update!(vcap_feature_flag: true, who_will_order_devices: 'responsible_body')
          old_school.update!(who_will_order_devices: 'responsible_body')
          old_school.can_order!
          rb.reload
        end

        it 'does not transfer any spare allocation or adjust the original values' do
          school = service.create_school!(staged_school)
          old_school.reload
          expect(old_school.in_virtual_cap_pool?).to be true

          expect(school.raw_allocation(:laptop)).to eq(0)
          expect(school.raw_allocation(:router)).to eq(0)
          expect(old_school.raw_allocation(:laptop)).to eq(100)
          expect(old_school.raw_cap(:laptop)).to eq(100)
          expect(old_school.raw_allocation(:router)).to eq(10)
          expect(old_school.raw_cap(:router)).to eq(10)
        end
      end
    end
  end

  describe '#schools_that_need_to_be_added' do
    let!(:staged_school) { create(:staged_school, urn: 103_001, status: school_status) }

    subject { service.schools_that_need_to_be_added }

    context 'when a staged school is closed' do
      let(:school_status) { 'closed' }

      it { is_expected.not_to include(staged_school) }
    end

    context 'when a staged school is open' do
      let(:school_status) { 'open' }

      context 'when the school was added already' do
        before { create(:school, urn: 103_001) }

        it { is_expected.not_to include(staged_school) }
      end

      context 'when the school was not added yet' do
        it { is_expected.to include(staged_school) }
      end
    end
  end

  describe '#schools_that_need_to_be_closed' do
    let!(:staged_school) { create(:staged_school, urn: 103_001, status: staged_school_status) }

    subject { service.schools_that_need_to_be_closed }

    context 'when a staged school is open' do
      let(:staged_school_status) { 'open' }

      it { is_expected.not_to include(staged_school) }
    end

    context 'when a staged school is closed' do
      let(:staged_school_status) { 'closed' }

      before { create(:school, urn: 103_001, status: school_status) }

      context 'when the school was closed already' do
        let(:school_status) { 'closed' }

        it { is_expected.not_to include(staged_school) }
      end

      context 'when the school was not closed yet' do
        let(:school_status) { 'open' }

        it { is_expected.to include(staged_school) }
      end
    end
  end
end
