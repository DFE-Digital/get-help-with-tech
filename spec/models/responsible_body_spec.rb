require 'rails_helper'

RSpec.describe ResponsibleBody, type: :model do
  subject(:responsible_body) { create(:local_authority) }

  before do
    stub_computacenter_outgoing_api_calls
  end

  describe '#active_schools' do
    let!(:schools) { create(:school, responsible_body:) }
    let(:closed_schools) { create(:school, status: 'closed', responsible_body:) }
    let(:la_funded_place) { create(:iss_provision, responsible_body:) }

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
      zebra = create(:school, name: 'Zebra', responsible_body:)
      aardvark = create(:school, name: 'Aardvark', responsible_body:)
      tiger = create(:school, name: 'Tiger', responsible_body:)

      expect(responsible_body.next_school_sorted_ascending_by_name(aardvark)).to eq(tiger)
      expect(responsible_body.next_school_sorted_ascending_by_name(tiger)).to eq(zebra)
    end

    it 'does not include LaFundedPlaces' do
      zebra = create(:school, name: 'Zebra', responsible_body:)
      aardvark = create(:school, name: 'Aardvark', responsible_body:)
      tiger = create(:school, name: 'Tiger', responsible_body:)
      create(:iss_provision, responsible_body:, name: 'Snake')

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
    let(:schools) { create_list(:school, 3, :centrally_managed, responsible_body:, laptops: [1, 0, 0]) }

    context 'when some schools are centrally managed' do
      before do
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        schools[2].update!(status: :closed)
      end

      it 'returns true' do
        expect(responsible_body.is_ordering_for_schools?).to be true
      end
    end

    context 'when no schools are centrally managed' do
      before do
        SchoolSetWhoManagesOrdersService.new(schools[0], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        schools[2].update!(status: :closed)
      end

      it 'returns false' do
        expect(responsible_body.is_ordering_for_schools?).to be false
      end
    end
  end

  describe '#has_centrally_managed_schools_that_can_order_now?' do
    let(:schools) { create_list(:school, 4, :with_preorder_information, laptops: [1, 0, 0], responsible_body:) }

    context 'when some schools are centrally managed' do
      before do
        SchoolSetWhoManagesOrdersService.new(schools[0], :responsible_body).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :responsible_body).call
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
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
        let(:la_funded_place) { create(:iss_provision, :centrally_managed, laptops: [1, 0, 0], responsible_body:) }

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
        SchoolSetWhoManagesOrdersService.new(schools[0], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
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
        let(:la_funded_place) { create(:iss_provision, :manages_orders, laptops: [1, 0, 0], responsible_body:) }

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

    let(:schools) { create_list(:school, 4, :with_preorder_information, responsible_body:, laptops: [1, 0, 0]) }

    context 'when some schools are centrally managed' do
      before do
        SchoolSetWhoManagesOrdersService.new(schools[0], :responsible_body).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :responsible_body).call
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
        schools[3].update!(status: :closed)
      end

      it 'returns true' do
        expect(responsible_body.has_centrally_managed_schools?).to be true
      end
    end

    context 'when no schools are centrally managed' do
      before do
        SchoolSetWhoManagesOrdersService.new(schools[0], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
        schools[3].update!(status: :closed)
      end

      it 'returns false' do
        expect(responsible_body.has_centrally_managed_schools?).to be false
      end
    end
  end

  describe '#has_schools_that_can_order_devices_now?' do
    let(:schools) { create_list(:school, 4, :with_preorder_information, responsible_body:, laptops: [1, 0, 0]) }

    context 'when some schools that will order are able to order devices' do
      before do
        SchoolSetWhoManagesOrdersService.new(schools[0], :responsible_body).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
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
        SchoolSetWhoManagesOrdersService.new(schools[0], :responsible_body).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
        schools[0].can_order!
        schools[1].cannot_order!
        schools[2].cannot_order!
        schools[3].update!(status: :closed)
      end

      it 'returns false' do
        expect(responsible_body.has_schools_that_can_order_devices_now?).to be false
      end

      context 'when LA funded places are present' do
        let(:la_funded_place) { create(:iss_provision, :manages_orders, laptops: [1, 0, 0], responsible_body:) }

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
    let(:schools) { create_list(:school, 4, :with_preorder_information, responsible_body:, laptops: [1, 0, 0]) }

    context 'when some centrally managed schools are able to order devices' do
      before do
        SchoolSetWhoManagesOrdersService.new(schools[0], :responsible_body).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
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
        SchoolSetWhoManagesOrdersService.new(schools[0], :responsible_body).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
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
        SchoolSetWhoManagesOrdersService.new(schools[0], :responsible_body).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
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
      let(:la_funded_place) { create(:iss_provision, :manages_orders, responsible_body:, laptops: [1, 0, 0]) }

      before do
        schools.each(&:cannot_order!)
        la_funded_place.can_order!
      end

      it 'does not include the LA funded place' do
        expect(responsible_body).not_to have_any_schools_that_can_order_now
      end
    end
  end

  describe '#calculate_laptop_vcap' do
    context 'case 1' do
      subject(:rb) { create(:trust, :manages_centrally, :vcap) }

      let(:school_a) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 0, 0]) }
      let(:school_b) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 10, 20]) }

      before do
        rb.update!(laptop_allocation: 20, laptop_cap: 30, laptops_ordered: 20)
      end

      it 'balances cap decreasing over increased cap' do
        expect(school_a.raw_laptops).to eq([10, 10, 0])
        expect(school_b.raw_laptops).to eq([10, 20, 20])
        expect(rb.laptops).to eq([20, 30, 20])

        rb.calculate_laptop_vcap

        expect(rb.laptops).to eq([20, 20, 20])
        expect(school_a.reload.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_b.reload.raw_laptops_full).to eq([10, 0, 10, 20])
        expect(school_a.raw_laptops).to eq([10, 0, 0])
        expect(school_b.raw_laptops).to eq([10, 20, 20])
      end
    end

    context 'case 2' do
      subject(:rb) { create(:trust, :manages_centrally, :vcap) }

      let!(:school_a) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [43, 0, -43, 0]) }
      let!(:school_b) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [15, 0, 63, 78]) }
      let!(:school_c) { create(:school, :centrally_managed, responsible_body: rb, laptops: [20, 0, 0, 0]) }

      before do
        rb.update!(laptop_allocation: 78, laptop_cap: 78, laptops_ordered: 78)
      end

      it 'do not touch over-ordered distribution when there is no room for redistribution' do
        expect(school_a.raw_laptops).to eq([43, 0, 0])
        expect(school_b.raw_laptops).to eq([15, 78, 78])
        expect(school_c.raw_laptops).to eq([20, 0, 0])
        expect(rb.laptops).to eq([78, 78, 78])

        rb.calculate_laptop_vcap

        expect(rb.reload.laptops).to eq([78, 78, 78])
        expect(school_a.reload.raw_laptops).to eq([43, 0, 0])
        expect(school_b.reload.raw_laptops).to eq([15, 78, 78])
        expect(school_c.reload.raw_laptops).to eq([20, 0, 0])
        expect(school_a.raw_laptops_full).to eq([43, 0, -43, 0])
        expect(school_b.raw_laptops_full).to eq([15, 0, 63, 78])
        expect(school_c.raw_laptops_full).to eq([20, 0, 0, 0])
      end
    end

    context 'case 3' do
      subject(:rb) { create(:trust, :manages_centrally, :vcap) }

      let!(:school_a) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [43, 0, -43, 0]) }
      let!(:school_b) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [15, 0, 40, 55]) }
      let!(:school_c) { create(:school, :centrally_managed, responsible_body: rb, laptops: [20, 0, 0, 0]) }

      before do
        rb.update!(laptop_allocation: 78, laptop_cap: 55, laptops_ordered: 55)
      end

      it 'balances cap increasing over decreased cap' do
        expect(school_a.raw_laptops).to eq([43, 0, 0])
        expect(school_b.raw_laptops).to eq([15, 55, 55])
        expect(school_c.raw_laptops).to eq([20, 0, 0])
        expect(rb.laptops).to eq([78, 55, 55])

        rb.calculate_laptop_vcap

        expect(rb.reload.laptops).to eq([78, 58, 55])
        expect(school_a.reload.raw_laptops).to eq([43, 3, 0])
        expect(school_b.reload.raw_laptops).to eq([15, 55, 55])
        expect(school_c.reload.raw_laptops).to eq([20, 0, 0])
        expect(school_a.raw_laptops_full).to eq([43, 0, -40, 0])
        expect(school_b.raw_laptops_full).to eq([15, 0, 40, 55])
        expect(school_c.raw_laptops_full).to eq([20, 0, 0, 0])
      end
    end

    context 'case 4' do
      subject(:rb) { create(:trust, :manages_centrally, :vcap) }

      let!(:school_a) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 0, 0]) }
      let!(:school_b) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 0, 0]) }
      let!(:school_c) { create(:school, :centrally_managed, responsible_body: rb, laptops: [10, 0, 20, 30]) }

      it 'do not touch over-ordered distribution when there is no room for redistribution' do
        expect(school_a.raw_laptops).to eq([10, 10, 0])
        expect(school_b.raw_laptops).to eq([10, 10, 0])
        expect(school_c.raw_laptops).to eq([10, 30, 30])
        expect(rb.laptops).to eq([0, 0, 0])

        rb.calculate_laptop_vcap

        expect(rb.reload.laptops).to eq([30, 30, 30])
        expect(school_a.reload.raw_laptops).to eq([10, 0, 0])
        expect(school_b.reload.raw_laptops).to eq([10, 0, 0])
        expect(school_c.reload.raw_laptops).to eq([10, 30, 30])
        expect(school_a.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_b.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_c.raw_laptops_full).to eq([10, 0, 20, 30])
      end
    end

    context 'case 5' do
      subject(:rb) { create(:trust, :manages_centrally, :vcap) }

      let(:alert) { 'Unable to reclaim all of the cap in the vcap to cover the over-order' }
      let!(:school_a) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 0, 0]) }
      let!(:school_b) { create(:school, :centrally_managed, responsible_body: rb, laptops: [10, 0, 0, 0]) }
      let!(:school_c) { create(:school, :centrally_managed, responsible_body: rb, laptops: [10, 0, 20, 30]) }

      before do
        allow(Sentry).to receive(:capture_message)
      end

      it 'recomputes vcap and balances cap. vcap schools that cannot order never lend cap' do
        expect(school_a.raw_laptops).to eq([10, 10, 0])
        expect(school_b.raw_laptops).to eq([10, 0, 0])
        expect(school_c.raw_laptops).to eq([10, 30, 30])
        expect(rb.laptops).to eq([0, 0, 0])

        rb.calculate_laptop_vcap

        expect(rb.reload.laptops).to eq([30, 30, 30])
        expect(school_a.reload.raw_laptops).to eq([10, 0, 0])
        expect(school_b.reload.raw_laptops).to eq([10, 0, 0])
        expect(school_c.reload.raw_laptops).to eq([10, 30, 30])
        expect(school_a.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_b.raw_laptops_full).to eq([10, 0, 0, 0])
        expect(school_c.raw_laptops_full).to eq([10, 0, 20, 30])
        expect(Sentry).to have_received(:capture_message).with(alert)
      end
    end

    context 'case 6' do
      subject(:rb) { create(:trust, :manages_centrally, :vcap) }

      let!(:school_a) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 0, 0]) }
      let!(:school_b) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 0, 0]) }
      let!(:school_c) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 20, 30]) }

      before do
        allow(Sentry).to receive(:capture_message)
        rb.calculate_laptop_vcap
      end

      it 'do not touch over-ordered distribution when there is no room for redistribution' do
        expect(school_a.reload.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_b.reload.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_c.reload.raw_laptops_full).to eq([10, 0, 20, 30])
        expect(rb.laptops).to eq([30, 30, 30])

        school_c.cannot_order!
        rb.calculate_laptop_vcap

        expect(rb.reload.laptops).to eq([30, 30, 30])
        expect(school_a.reload.raw_laptops).to eq([10, 0, 0])
        expect(school_b.reload.raw_laptops).to eq([10, 0, 0])
        expect(school_c.reload.raw_laptops).to eq([10, 30, 30])
        expect(school_a.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_b.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_c.raw_laptops_full).to eq([10, 0, 20, 30])
        expect(Sentry).not_to have_received(:capture_message)
      end
    end

    context 'case 7' do
      subject(:rb) { create(:trust, :manages_centrally, :vcap) }

      let!(:school_a) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 0, 0]) }
      let!(:school_b) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 0, 0]) }
      let!(:school_c) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 20, 30]) }

      before do
        allow(Sentry).to receive(:capture_message)
        rb.calculate_laptop_vcap
      end

      it 'do not touch over-ordered distribution when there is no room for redistribution' do
        expect(school_a.reload.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_b.reload.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_c.reload.raw_laptops_full).to eq([10, 0, 20, 30])
        expect(rb.laptops).to eq([30, 30, 30])

        school_b.cannot_order!
        rb.calculate_laptop_vcap

        expect(rb.reload.laptops).to eq([30, 30, 30])
        expect(school_a.reload.raw_laptops).to eq([10, 0, 0])
        expect(school_b.reload.raw_laptops).to eq([10, 0, 0])
        expect(school_c.reload.raw_laptops).to eq([10, 30, 30])
        expect(school_a.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_b.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_c.raw_laptops_full).to eq([10, 0, 20, 30])
        expect(Sentry).not_to have_received(:capture_message)
      end
    end

    context 'case 8' do
      subject(:rb) { create(:trust, :manages_centrally, :vcap) }

      let!(:school_a) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, -10, 0]) }
      let!(:school_b) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, -10, 0]) }
      let!(:school_c) { create(:school, :in_lockdown, :centrally_managed, responsible_body: rb, laptops: [10, 0, 20, 30]) }

      before do
        allow(Sentry).to receive(:capture_message)
        rb.calculate_laptop_vcap
      end

      it 'redistribute over-ordered cap so that schools that cannot order get their lent cap asap' do
        expect(school_a.reload.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_b.reload.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_c.reload.raw_laptops_full).to eq([10, 0, 20, 30])
        expect(rb.laptops).to eq([30, 30, 30])

        school_b.cannot_order!
        school_c.update!(raw_laptops_ordered: 20, over_order_reclaimed_laptops: 10)
        rb.calculate_laptop_vcap

        expect(rb.reload.laptops).to eq([30, 20, 20])
        expect(school_a.reload.raw_laptops).to eq([10, 0, 0])
        expect(school_b.reload.raw_laptops).to eq([10, 0, 0])
        expect(school_c.reload.raw_laptops).to eq([10, 20, 20])
        expect(school_a.raw_laptops_full).to eq([10, 0, -10, 0])
        expect(school_b.raw_laptops_full).to eq([10, 0, 0, 0])
        expect(school_c.raw_laptops_full).to eq([10, 0, 10, 20])
        expect(Sentry).not_to have_received(:capture_message)
      end
    end
  end

  describe '#calculate_vcaps!' do
    subject(:responsible_body) { create(:trust, :manages_centrally, :vcap) }

    let(:schools) do
      create_list(:school, 3,
                  :centrally_managed,
                  :in_lockdown,
                  laptops: [1, 1, 0],
                  routers: [1, 1, 0],
                  responsible_body:)
    end

    before do
      schools.each do |s|
        UpdateSchoolDevicesService.new(school: s,
                                       order_state: :can_order_for_specific_circumstances,
                                       laptop_allocation: 2,
                                       laptops_ordered: 1,
                                       router_allocation: 3,
                                       circumstances_routers: -1,
                                       routers_ordered: 1).call
      end
    end

    it 'calculates the virtual cap for all device types' do
      UpdateSchoolDevicesService.new(school: schools.first,
                                     laptop_allocation: 3,
                                     laptops_ordered: 2).call
      UpdateSchoolDevicesService.new(school: schools.last,
                                     router_allocation: 3,
                                     circumstances_routers: -2,
                                     routers_ordered: 0).call
      expect(responsible_body.cap(:laptop)).to eq(7)
      expect(responsible_body.devices_ordered(:laptop)).to eq(4)
      expect(responsible_body.cap(:router)).to eq(5)
      expect(responsible_body.devices_ordered(:router)).to eq(2)
    end
  end

  describe '#has_school_in_virtual_cap_pools?' do
    subject(:responsible_body) { create(:trust, :manages_centrally, :vcap) }

    let(:schools) do
      create_list(:school,
                  2,
                  :centrally_managed,
                  :in_lockdown,
                  responsible_body:,
                  laptops: [1, 0, 0],
                  routers: [1, 0, 0])
    end

    it 'returns true for a school within the pool' do
      expect(responsible_body.has_school_in_virtual_cap_pools?(schools.first)).to be true
    end

    it 'returns false for a school outside the pool' do
      SchoolSetWhoManagesOrdersService.new(schools.last, :school).call
      expect(responsible_body.has_school_in_virtual_cap_pools?(schools.last)).to be false
    end
  end

  describe '#devices_available_to_order?' do
    subject(:responsible_body) { create(:trust, :manages_centrally, vcap: true) }

    let(:schools) do
      create_list(:school,
                  2,
                  :centrally_managed,
                  :in_lockdown,
                  responsible_body:,
                  laptops: [1, 1, 0],
                  routers: [1, 1, 0])
    end

    context 'when used full allocation' do
      before do
        UpdateSchoolDevicesService.new(school: schools.first, laptops_ordered: 1, routers_ordered: 1).call
        UpdateSchoolDevicesService.new(school: schools.last,
                                       laptops_ordered: 1,
                                       router_allocation: 2,
                                       routers_ordered: 2).call
      end

      it 'returns false' do
        expect(responsible_body.devices_available_to_order?).to be false
      end
    end

    context 'when partially used allocation' do
      before do
        UpdateSchoolDevicesService.new(school: schools.first,
                                       laptop_allocation: 2,
                                       laptops_ordered: 1).call
        UpdateSchoolDevicesService.new(school: schools.last,
                                       router_allocation: 1,
                                       routers_ordered: 1).call
      end

      it 'returns true' do
        expect(responsible_body.devices_available_to_order?).to be true
      end
    end

    context 'when no devices ordered' do
      before do
        UpdateSchoolDevicesService.new(school: schools.first,
                                       laptop_allocation: 1,
                                       laptops_ordered: 0).call
        UpdateSchoolDevicesService.new(school: schools.last,
                                       router_allocation: 2,
                                       over_order_reclaimed_routers: -1,
                                       routers_ordered: 0).call
      end

      it 'returns true' do
        expect(responsible_body.devices_available_to_order?).to be true
      end
    end
  end

  describe '#vcap_and_centrally_managed_schools?' do
    subject(:responsible_body) { create(:trust) }

    let(:schools) do
      create_list(:school,
                  4,
                  :centrally_managed,
                  responsible_body:,
                  laptops: [1, 0, 0])
    end

    context 'when some schools are centrally managed' do
      before do
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
        schools[3].update!(status: :closed)
      end

      context 'without any feature flags' do
        before do
          responsible_body.update!(vcap: false)
        end

        it 'returns false' do
          expect(responsible_body.vcap_and_centrally_managed_schools?).to be false
        end
      end

      context 'when responsible body flag is enabled' do
        before do
          responsible_body.update!(vcap: true)
        end

        it 'returns true' do
          expect(responsible_body.vcap_and_centrally_managed_schools?).to be true
        end
      end
    end

    context 'when no schools are centrally managed' do
      before do
        SchoolSetWhoManagesOrdersService.new(schools[0], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        SchoolSetWhoManagesOrdersService.new(schools[2], :school).call
        schools[3].update!(status: :closed)
      end

      context 'without any feature flags' do
        before do
          responsible_body.update!(vcap: false)
        end

        it 'returns false' do
          expect(responsible_body.vcap_and_centrally_managed_schools?).to be false
        end
      end

      context 'when responsible body flag is enabled' do
        before do
          responsible_body.update!(vcap: true)
        end

        it 'returns false' do
          expect(responsible_body.vcap_and_centrally_managed_schools?).to be false
        end
      end
    end
  end

  describe '.managing_multiple_chromebook_domains' do
    subject(:responsible_body) { create(:trust, :manages_centrally) }

    let(:second_rb) { create(:trust, :manages_centrally) }
    let(:third_rb) { create(:trust, :devolves_management) }

    let(:schools) { create_list(:school, 2, :centrally_managed, responsible_body:, laptops: [1, 0, 0]) }
    let(:second_schools) { create_list(:school, 2, :centrally_managed, responsible_body: second_rb, laptops: [1, 0, 0]) }
    let(:third_schools) { create_list(:school, 2, :centrally_managed, responsible_body: third_rb, laptops: [1, 0, 0]) }

    before do
      SchoolSetWhoManagesOrdersService.new(third_schools[0], :school).call
      SchoolSetWhoManagesOrdersService.new(third_schools[1], :school).call
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
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
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

    let(:schools) { create_list(:school, 2, :centrally_managed, responsible_body:, laptops: [1, 0, 0]) }

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
        SchoolSetWhoManagesOrdersService.new(schools[1], :school).call
        schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                             school_or_rb_domain: 'school1.google.com')
      end

      it 'returns false' do
        expect(responsible_body.has_multiple_chromebook_domains_in_managed_schools?).to be false
      end
    end
  end

  describe '#vcap_schools' do
    let(:responsible_body) { create(:trust, :manages_centrally, :vcap) }
    let(:centrally_managed_school) { create(:school, :centrally_managed, responsible_body:) }
    let(:management_not_set_school) { create(:school, responsible_body:, who_will_order_devices: nil) }
    let(:la_funded_place) { create(:iss_provision, responsible_body:) }

    before do
      centrally_managed_school
      management_not_set_school
      la_funded_place
    end

    context 'when the responsible body has vcaps disabled' do
      let(:responsible_body) { create(:trust, vcap: false) }

      it 'returns no schools' do
        expect(responsible_body.vcap_schools).to eq(School.none)
      end
    end

    context 'la_funded_provisions are never included' do
      it 'do not include la_funded_place' do
        expect(responsible_body.vcap_schools).not_to include(la_funded_place)
      end
    end

    context 'when the rb devolves device management to schools' do
      let(:responsible_body) { create(:trust, :vcap, :devolves_management) }

      it 'only include schools centrally managed' do
        vcap_schools = responsible_body.vcap_schools

        expect(vcap_schools).to include(centrally_managed_school)
        expect(vcap_schools).not_to include(management_not_set_school)
      end
    end

    context 'when the rb defaults to centrally managed schools' do
      let(:responsible_body) { create(:trust, :vcap, :manages_centrally) }

      it 'include schools not managing devices themselves' do
        vcap_schools = responsible_body.vcap_schools

        expect(vcap_schools).to include(centrally_managed_school)
        expect(vcap_schools).to include(management_not_set_school)
      end
    end
  end
end
