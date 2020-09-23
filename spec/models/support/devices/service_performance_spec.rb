require 'rails_helper'

RSpec.describe Support::Devices::ServicePerformance, type: :model do
  subject(:stats) { Support::Devices::ServicePerformance.new }

  describe '#responsible_body_users_signed_in_at_least_once' do
    it 'counts only responsible body users who have signed in at least once' do
      # the following should be counted
      create(:local_authority_user, :signed_in_before, responsible_body: create(:local_authority, in_devices_pilot: true))

      # the following should be ignored
      create(:dfe_user, :signed_in_before)
      create(:mno_user, :signed_in_before)
      create(:local_authority_user, :never_signed_in)

      expect(stats.responsible_body_users_signed_in_at_least_once).to eq(1)
    end
  end

  describe '#number_of_different_responsible_bodies_signed_in' do
    it 'counts only the responsible bodies where at least one user has signed in' do
      # this one should count
      local_authority = create(:local_authority, in_devices_pilot: true)
      create_list(:local_authority_user, 2, :signed_in_before, responsible_body: local_authority)

      # this one should count
      trust = create(:trust, in_devices_pilot: true)
      create(:trust_user, :signed_in_before, responsible_body: trust)
      create(:trust_user, :never_signed_in, responsible_body: trust)

      # this one shouldn't count as nobody's signed in
      create(:trust_user, :never_signed_in)

      # this one shouldn't count as it has no users
      create(:local_authority, in_devices_pilot: true)

      expect(stats.number_of_different_responsible_bodies_signed_in).to eq(2)
    end
  end

  describe '#number_of_different_responsible_bodies_who_have_chosen_who_will_order' do
    it 'counts only the responsible bodies who have a non-nil value in who_will_order_devices' do
      # these will count
      create_list(:local_authority, 3, in_devices_pilot: true, who_will_order_devices: 'responsible_body')
      create_list(:trust, 4, in_devices_pilot: true, who_will_order_devices: 'school')

      # these won't count
      create_list(:local_authority, 2, in_devices_pilot: true, who_will_order_devices: nil)

      expect(stats.number_of_different_responsible_bodies_who_have_chosen_who_will_order).to eq(7)
    end
  end

  describe '#number_of_different_responsible_bodies_with_at_least_one_preorder_information_completed' do
    it 'counts the number of unique responsible bodies where there is at least one school with preorder information that is not in a "needs_(x)" status' do
      # these will count
      rbs = create_list(:local_authority, 3, in_devices_pilot: true)
      schools = []
      rbs.each do |rb|
        schools << create(:school, responsible_body: rb)
      end
      create(:preorder_information, school: schools[0], status: 'school_will_be_contacted')
      create(:preorder_information, school: schools[1], status: 'school_contacted')
      create(:preorder_information, school: schools[0], status: 'ready')

      # these won't count
      trusts = create_list(:trust, 2, in_devices_pilot: true)
      school = create(:school, responsible_body: trusts[0])
      create(:preorder_information, school: school, status: 'needs_info')
      school1 = create(:school, responsible_body: trusts[1])
      create(:preorder_information, school: school1, status: 'needs_contact')

      expect(stats.number_of_different_responsible_bodies_with_at_least_one_preorder_information_completed).to eq(2)
    end
  end

  describe 'status-counting methods' do
    before do
      create_list(:preorder_information, 5, status: 'needs_info')
      create_list(:preorder_information, 2, status: 'needs_contact')
      create_list(:preorder_information, 2, status: 'school_will_be_contacted')
      create_list(:preorder_information, 2, status: 'school_contacted')
      create_list(:preorder_information, 3, status: 'ready')
      create_list(:preorder_information, 7, status: 'school_ready')
      ResponsibleBody.update_all(in_devices_pilot: true)
    end

    describe 'preorder_information_counts_by_status' do
      it 'returns the total number of preorder_information records with each status' do
        expect(stats.preorder_information_counts_by_status['needs_info']).to eq(5)
        expect(stats.preorder_information_counts_by_status['needs_contact']).to eq(2)
        expect(stats.preorder_information_counts_by_status['school_will_be_contacted']).to eq(2)
        expect(stats.preorder_information_counts_by_status['school_contacted']).to eq(2)
        expect(stats.preorder_information_counts_by_status['ready']).to eq(3)
        expect(stats.preorder_information_counts_by_status['school_ready']).to eq(7)
      end
    end

    describe '#preorder_information_by_status' do
      it 'returns the count of records with the given status' do
        expect(stats.preorder_information_by_status('needs_info')).to eq(5)
        expect(stats.preorder_information_by_status('needs_contact')).to eq(2)
        expect(stats.preorder_information_by_status('school_will_be_contacted')).to eq(2)
        expect(stats.preorder_information_by_status('school_contacted')).to eq(2)
        expect(stats.preorder_information_by_status('ready')).to eq(3)
        expect(stats.preorder_information_counts_by_status['school_ready']).to eq(7)
      end
    end

    describe '#number_of_schools_managed_centrally' do
      it 'adds up the number of schools in status "needs_info" and "ready"' do
        expect(stats.number_of_schools_managed_centrally).to eq(8)
      end
    end

    describe '#number_of_schools_devolved_to' do
      it 'adds up the number of schools in status needs_contact, school_will_be_contacted, school_contacted and school_ready' do
        expect(stats.number_of_schools_devolved_to).to eq(13)
      end
    end

    describe '#number_of_schools_with_a_decision_made' do
      it 'calculates the total number of schools devolved or managed centrally' do
        expect(stats.number_of_schools_with_a_decision_made).to eq(21)
      end
    end
  end
end
