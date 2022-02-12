require 'rails_helper'

RSpec.describe Support::ServicePerformance, type: :model do
  subject(:stats) { described_class.new }

  describe '#responsible_body_users_signed_in_at_least_once' do
    it 'counts only responsible body users who have signed in at least once' do
      # the following should be counted
      create(:local_authority_user, :signed_in_before, responsible_body: create(:local_authority))

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
      local_authority = create(:local_authority)
      create_list(:local_authority_user, 2, :signed_in_before, responsible_body: local_authority)

      # this one should count
      trust = create(:trust)
      create(:trust_user, :signed_in_before, responsible_body: trust)
      create(:trust_user, :never_signed_in, responsible_body: trust)

      # this one shouldn't count as nobody's signed in
      create(:trust_user, :never_signed_in)

      # this one shouldn't count as it has no users
      create(:local_authority)

      expect(stats.number_of_different_responsible_bodies_signed_in).to eq(2)
    end
  end

  describe '#number_of_different_responsible_bodies_with_at_least_one_preorder_information_completed' do
    it 'counts the number of unique responsible bodies where there is at least one school with preorder information that is not in a "needs_(x)" status' do
      # these will count
      create_schools_at_status(preorder_status: 'school_will_be_contacted')
      create_schools_at_status(preorder_status: 'school_contacted')
      create_schools_at_status(preorder_status: 'ready')

      # these won't count
      create_schools_at_status(preorder_status: 'needs_info')
      create_schools_at_status(preorder_status: 'needs_contact')

      expect(stats.number_of_different_responsible_bodies_with_at_least_one_preorder_information_completed).to eq(3)
    end
  end

  describe 'status-counting methods' do
    before do
      create_schools_at_status(preorder_status: 'needs_info', count: 5)
      create_schools_at_status(preorder_status: 'needs_contact', count: 2)
      create_schools_at_status(preorder_status: 'school_will_be_contacted', count: 2)
      create_schools_at_status(preorder_status: 'school_contacted', count: 2)
      create_schools_at_status(preorder_status: 'ready', count: 3)
      create_schools_at_status(preorder_status: 'school_ready', count: 7)
    end

    describe 'preorder_information_counts_by_status' do
      it 'returns the total number of preorder_information records with each status' do
        expect(stats.school_counts_by_status['needs_info']).to eq(5)
        expect(stats.school_counts_by_status['needs_contact']).to eq(2)
        expect(stats.school_counts_by_status['school_will_be_contacted']).to eq(2)
        expect(stats.school_counts_by_status['school_contacted']).to eq(2)
        expect(stats.school_counts_by_status['ready']).to eq(3)
        expect(stats.school_counts_by_status['school_ready']).to eq(7)
      end
    end

    describe '#preorder_information_by_status' do
      it 'returns the count of records with the given status' do
        expect(stats.school_by_status('needs_info')).to eq(5)
        expect(stats.school_by_status('needs_contact')).to eq(2)
        expect(stats.school_by_status('school_will_be_contacted')).to eq(2)
        expect(stats.school_by_status('school_contacted')).to eq(2)
        expect(stats.school_by_status('ready')).to eq(3)
        expect(stats.school_counts_by_status['school_ready']).to eq(7)
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

  describe 'extra mobile data requests' do
    before do
      create_list(:extra_mobile_data_request, 5,
                  mobile_network: create(:mobile_network, brand: '2nd Best'), status: :new)
      create_list(:extra_mobile_data_request, 2,
                  mobile_network: create(:mobile_network, brand: 'Thirdy'), status: :in_progress)
      create_list(:extra_mobile_data_request, 10, :with_problem,
                  mobile_network: create(:mobile_network, brand: 'Top Telecom'))
    end

    describe '#total_extra_mobile_data_requests' do
      it 'returns the total number of requests' do
        expect(stats.total_extra_mobile_data_requests).to eq(17)
      end
    end

    describe '#extra_mobile_data_requests_by_status' do
      it 'returns the counts by status' do
        expect(stats.extra_mobile_data_requests_by_status).to include(
          'new' => 5,
          'in_progress' => 2,
        )
      end
    end

    describe '#total_extra_mobile_data_requests_with_problems' do
      it 'returns the counts of requests with problem statuses' do
        expect(stats.total_extra_mobile_data_requests_with_problems).to eq(10)
      end
    end

    describe '#extra_mobile_data_requests_by_mobile_network_brand' do
      it 'returns the counts by network brand name, descending' do
        expect(stats.extra_mobile_data_requests_by_mobile_network_brand).to eq(
          [
            ['Top Telecom', 10],
            ['2nd Best', 5],
            ['Thirdy', 2],
          ],
        )
      end
    end
  end

  describe '#extra_mobile_data_request_completions' do
    before do
      create_list(:reportable_event, 4, :extra_mobile_data_request_completion, event_time: 2.weeks.ago)
      create_list(:reportable_event, 2, :extra_mobile_data_request_completion, event_time: 1.week.ago)
      create_list(:reportable_event, 1, :extra_mobile_data_request_completion, event_time: 2.hours.ago)
      create_list(:reportable_event, 3, :extra_mobile_data_request_completion, event_time: Time.zone.now.utc + 2.hours)
    end

    context 'given no params' do
      it 'returns the total number of completions regardless of time' do
        expect(stats.extra_mobile_data_request_completions).to eq(10)
      end
    end

    context 'given a datetime as from:' do
      it 'returns the total number of completions after the given datetime' do
        expect(stats.extra_mobile_data_request_completions(from: 10.days.ago)).to eq(6)
      end

      context 'given a datetime as to:' do
        it 'returns the total number of completions between the given datetimes' do
          expect(stats.extra_mobile_data_request_completions(from: 10.days.ago, to: 2.minutes.ago)).to eq(3)
        end
      end
    end

    context 'given a datetime as to:' do
      it 'returns the total number of completions before the given datetime' do
        expect(stats.extra_mobile_data_request_completions(to: 10.days.ago)).to eq(4)
      end
    end
  end

  describe '#segmented_device_counts' do
    let(:rb_devolved_1) { create(:trust, :devolves_management) }
    let(:rb_devolved_2) { create(:trust, :devolves_management) }
    let(:rb_centrally_managed_1) { create(:local_authority, :manages_centrally) }
    let(:rb_centrally_managed_2) { create(:local_authority, :manages_centrally) }

    let :schools_state do
      [
        {
          rb: rb_devolved_1,
          devolved: true,
          schools: [
            { open: true,  laptops: [2, 0, 0, 0] },
            { open: true,  laptops: [2, 0, -1, 1] },
            { open: true,  laptops: [2, -1, 0, 1] },
            { open: false, laptops: [2, 0, 0, 0] },
            { open: false, laptops: [2, 0, 1, 3] },
          ],
        },
        {
          rb: rb_devolved_2,
          devolved: true,
          schools: [
            { open: true,  laptops: [2, 0, 0, 0] },
            { open: true,  laptops: [2, 0, 0, 1] },
            { open: true,  laptops: [2, 0, 1, 3] },
            { open: false, laptops: [2, 0, 0, 0] },
            { open: false, laptops: [2, 0, 0, 1] },
            { open: false, laptops: [2, 0, 1, 3] },
          ],
        },
        {
          rb: rb_centrally_managed_1,
          devolved: false,
          schools: [
            { open: true,  laptops: [2, 0, 0, 0] },
            { open: true,  laptops: [2, 0, 0, 1] },
            { open: true,  laptops: [2, 0, 1, 3] },
            { open: true,  laptops: [2, 0, 2, 4] },
            { open: false, laptops: [2, 0, 0, 0] },
          ],
        },
        {
          rb: rb_centrally_managed_2,
          devolved: false,
          schools: [
            { open: true,  laptops: [2, 0, 0, 0] },
            { open: true,  laptops: [2, 0, 0, 1] },
            { open: true,  laptops: [2, -2, 0, 0] },
            { open: false, laptops: [2, 0, 0, 0] },
            { open: false, laptops: [2, 0, 3, 5] },
            { open: false, laptops: [2, 0, 1, 3] },
          ],
        },
      ]
    end

    let :expected_result do
      [
        {
          key: :open_and_devolved_schools,
          allocated: 11,
          ordered: 6,
          allocation_liability: 5,
          over_ordered: 0,
        },
        {
          key: :closed_and_devolved_schools,
          allocated: 10,
          ordered: 7,
          allocation_liability: 5,
          over_ordered: 2,
        },
        {
          key: :open_and_centrally_managed_schools,
          allocated: 12,
          ordered: 9,
          allocation_liability: 6,
          over_ordered: 3,
        },
        {
          key: :closed_and_centrally_managed_schools,
          allocated: 8,
          ordered: 8,
          allocation_liability: 4,
          over_ordered: 4,
        },
      ]
    end

    before do
      stub_computacenter_outgoing_api_calls
      schools_state.each do |entry|
        entry[:schools].each do |school_data|
          school_record = create(
            :school,
            :in_lockdown,
            responsible_body: entry[:rb],
            status: school_data[:open] ? 'open' : 'closed',
            laptops: school_data[:laptops],
          )

          if entry[:devolved]
            SchoolSetWhoManagesOrdersService.new(school_record, :school).call
          else
            SchoolSetWhoManagesOrdersService.new(school_record, :responsible_body).call
          end
        end
      end
    end

    it 'produces the expected segmented device counts' do
      result = stats.segmented_device_counts

      expect(result.length).to eq 4

      expected_result.each_with_index do |expected_result_segment, ix|
        result_segment = {
          key: result[ix].key,
          allocated: result[ix].allocated,
          ordered: result[ix].ordered,
          allocation_liability: result[ix].allocation_liability,
          over_ordered: result[ix].over_ordered,
        }

        expect(result_segment).to eq expected_result_segment
      end
    end
  end

  describe 'totals' do
    let(:rb) { create(:local_authority, :vcap, :manages_centrally) }

    context 'cannot_order school centrally managed with allocation matching cap' do
      before do
        create(:school, :centrally_managed, laptops: [10, 0, 0, 1], routers: [10, 0, 0, 1], responsible_body: rb)
      end

      it 'compute the right total amounts of laptops' do
        expect(stats.total_devices_allocated).to eq(1)
        expect(stats.total_devices_over_ordered).to eq(0)
        expect(stats.total_devices_cap).to eq(1)
        expect(stats.total_devices_ordered).to eq(1)
        expect(stats.total_devices_allocation_liability).to eq(0)
      end

      it 'compute the right total amounts of routers' do
        expect(stats.total_routers_allocated).to eq(1)
        expect(stats.total_routers_over_ordered).to eq(0)
        expect(stats.total_routers_cap).to eq(1)
        expect(stats.total_routers_ordered).to eq(1)
        expect(stats.total_routers_allocation_liability).to eq(0)
      end
    end

    context 'in-lockdown school centrally managed with allocation matching cap' do
      before do
        create(:school, :centrally_managed, :in_lockdown, laptops: [10, 0, 0, 1], routers: [10, 0, 0, 1], responsible_body: rb)
      end

      it 'compute the right total amounts of laptops' do
        expect(stats.total_devices_allocated).to eq(10)
        expect(stats.total_devices_over_ordered).to eq(0)
        expect(stats.total_devices_cap).to eq(10)
        expect(stats.total_devices_ordered).to eq(1)
        expect(stats.total_devices_allocation_liability).to eq(9)
      end

      it 'compute the right total amounts of routers' do
        expect(stats.total_routers_allocated).to eq(10)
        expect(stats.total_routers_over_ordered).to eq(0)
        expect(stats.total_routers_cap).to eq(10)
        expect(stats.total_routers_ordered).to eq(1)
        expect(stats.total_routers_allocation_liability).to eq(9)
      end
    end

    context 'in-lockdown school centrally managed with over ordered lent devices' do
      before do
        create(:school, :centrally_managed, :in_lockdown, laptops: [10, 0, -9, 1], routers: [10, 0, -9, 1], responsible_body: rb)
      end

      it 'compute the right total amounts of laptops' do
        expect(stats.total_devices_allocated).to eq(10)
        expect(stats.total_devices_over_ordered).to eq(-9)
        expect(stats.total_devices_cap).to eq(1)
        expect(stats.total_devices_ordered).to eq(1)
        expect(stats.total_devices_allocation_liability).to eq(0)
      end

      it 'compute the right total amounts of routers' do
        expect(stats.total_routers_allocated).to eq(10)
        expect(stats.total_routers_over_ordered).to eq(-9)
        expect(stats.total_routers_cap).to eq(1)
        expect(stats.total_routers_ordered).to eq(1)
        expect(stats.total_routers_allocation_liability).to eq(0)
      end
    end

    context 'in-lockdown school centrally managed with over ordered borrowed devices' do
      before do
        create(:school, :centrally_managed, :in_lockdown, laptops: [10, 0, 9, 19], routers: [10, 0, 9, 19], responsible_body: rb)
      end

      it 'compute the right total amounts of laptops' do
        expect(stats.total_devices_allocated).to eq(10)
        expect(stats.total_devices_over_ordered).to eq(9)
        expect(stats.total_devices_cap).to eq(19)
        expect(stats.total_devices_ordered).to eq(19)
        expect(stats.total_devices_allocation_liability).to eq(0)
      end

      it 'compute the right total amounts of routers' do
        expect(stats.total_routers_allocated).to eq(10)
        expect(stats.total_routers_over_ordered).to eq(9)
        expect(stats.total_routers_cap).to eq(19)
        expect(stats.total_routers_ordered).to eq(19)
        expect(stats.total_routers_allocation_liability).to eq(0)
      end
    end

    context 'can_order_for_specific_circumstances school centrally managed' do
      before do
        create(:school, :centrally_managed, :can_order_for_specific_circumstances, laptops: [10, -3, 0, 3], routers: [10, -3, 0, 3], responsible_body: rb)
      end

      it 'compute the right total amounts of laptops' do
        expect(stats.total_devices_allocated).to eq(7)
        expect(stats.total_devices_over_ordered).to eq(0)
        expect(stats.total_devices_cap).to eq(7)
        expect(stats.total_devices_ordered).to eq(3)
        expect(stats.total_devices_allocation_liability).to eq(4)
      end

      it 'compute the right total amounts of routers' do
        expect(stats.total_routers_allocated).to eq(7)
        expect(stats.total_routers_over_ordered).to eq(0)
        expect(stats.total_routers_cap).to eq(7)
        expect(stats.total_routers_ordered).to eq(3)
        expect(stats.total_routers_allocation_liability).to eq(4)
      end
    end

    context 'can_order_for_specific_circumstances school not centrally managed' do
      before do
        create(:school, :manages_orders, :can_order_for_specific_circumstances, laptops: [10, -3, 0, 3], routers: [10, -3, 0, 3], responsible_body: rb)
      end

      it 'compute the right total amounts of laptops' do
        expect(stats.total_devices_allocated).to eq(7)
        expect(stats.total_devices_over_ordered).to eq(0)
        expect(stats.total_devices_cap).to eq(7)
        expect(stats.total_devices_ordered).to eq(3)
        expect(stats.total_devices_allocation_liability).to eq(4)
      end

      it 'compute the right total amounts of routers' do
        expect(stats.total_routers_allocated).to eq(7)
        expect(stats.total_routers_over_ordered).to eq(0)
        expect(stats.total_routers_cap).to eq(7)
        expect(stats.total_routers_ordered).to eq(3)
        expect(stats.total_routers_allocation_liability).to eq(4)
      end
    end

    context 'cannot_order school not centrally managed with allocation matching cap' do
      before do
        create(:school, :manages_orders, laptops: [10, 0, 0, 1], routers: [10, 0, 0, 1])
      end

      it 'compute the right total amounts of laptops' do
        expect(stats.total_devices_allocated).to eq(1)
        expect(stats.total_devices_over_ordered).to eq(0)
        expect(stats.total_devices_cap).to eq(1)
        expect(stats.total_devices_ordered).to eq(1)
        expect(stats.total_devices_allocation_liability).to eq(0)
      end

      it 'compute the right total amounts of routers' do
        expect(stats.total_routers_allocated).to eq(1)
        expect(stats.total_routers_over_ordered).to eq(0)
        expect(stats.total_routers_cap).to eq(1)
        expect(stats.total_routers_ordered).to eq(1)
        expect(stats.total_routers_allocation_liability).to eq(0)
      end
    end

    context 'in-lockdown school not centrally managed with allocation matching cap' do
      before do
        create(:school, :manages_orders, :in_lockdown, laptops: [10, 0, 0, 1], routers: [10, 0, 0, 1])
      end

      it 'compute the right total amounts of laptops' do
        expect(stats.total_devices_allocated).to eq(10)
        expect(stats.total_devices_over_ordered).to eq(0)
        expect(stats.total_devices_cap).to eq(10)
        expect(stats.total_devices_ordered).to eq(1)
        expect(stats.total_devices_allocation_liability).to eq(9)
      end

      it 'compute the right total amounts of routers' do
        expect(stats.total_routers_allocated).to eq(10)
        expect(stats.total_routers_over_ordered).to eq(0)
        expect(stats.total_routers_cap).to eq(10)
        expect(stats.total_routers_ordered).to eq(1)
        expect(stats.total_routers_allocation_liability).to eq(9)
      end
    end

    context 'in-lockdown school not centrally managed with over ordered borrowed devices' do
      before do
        create(:school, :manages_orders, :in_lockdown, laptops: [10, 0, 4, 14], routers: [10, 0, 4, 14])
      end

      it 'compute the right total amounts of laptops' do
        expect(stats.total_devices_allocated).to eq(10)
        expect(stats.total_devices_over_ordered).to eq(4)
        expect(stats.total_devices_cap).to eq(14)
        expect(stats.total_devices_ordered).to eq(14)
        expect(stats.total_devices_allocation_liability).to eq(0)
      end

      it 'compute the right total amounts of routers' do
        expect(stats.total_routers_allocated).to eq(10)
        expect(stats.total_routers_over_ordered).to eq(4)
        expect(stats.total_routers_cap).to eq(14)
        expect(stats.total_routers_ordered).to eq(14)
        expect(stats.total_routers_allocation_liability).to eq(0)
      end
    end

    context 'with all types of schools' do
      before do
        create(:school, :centrally_managed, laptops: [10, 0, 0, 1], routers: [10, 0, 0, 1], responsible_body: rb)
        create(:school, :centrally_managed, :in_lockdown, laptops: [10, 0, 0, 1], routers: [10, 0, 0, 1], responsible_body: rb)
        create(:school, :centrally_managed, :in_lockdown, laptops: [10, 0, -9, 1], routers: [10, 0, -9, 1], responsible_body: rb)
        create(:school, :centrally_managed, :in_lockdown, laptops: [10, 0, 9, 19], routers: [10, 0, 9, 19], responsible_body: rb)
        create(:school, :centrally_managed, :in_lockdown, :can_order_for_specific_circumstances, laptops: [10, -3, 0, 3], routers: [10, -3, 0, 3], responsible_body: rb)
        create(:school, :manages_orders, :can_order_for_specific_circumstances, laptops: [10, -3, 0, 3], routers: [10, -3, 0, 3], responsible_body: rb)
        create(:school, :manages_orders, laptops: [10, 0, 0, 1], routers: [10, 0, 0, 1])
        create(:school, :manages_orders, :in_lockdown, laptops: [10, 0, 0, 1], routers: [10, 0, 0, 1])
        create(:school, :manages_orders, :in_lockdown, laptops: [10, 0, 4, 14], routers: [10, 0, 4, 14])
      end

      it 'compute the right total amounts for devices' do
        expect(stats.total_devices_allocated).to eq(66)
        expect(stats.total_devices_over_ordered).to eq(4)
        expect(stats.total_devices_cap).to eq(70)
        expect(stats.total_devices_ordered).to eq(44)
        expect(stats.total_devices_allocation_liability).to eq(26)
      end

      it 'compute the right total amounts for routers' do
        expect(stats.total_routers_allocated).to eq(66)
        expect(stats.total_routers_over_ordered).to eq(4)
        expect(stats.total_routers_cap).to eq(70)
        expect(stats.total_routers_ordered).to eq(44)
        expect(stats.total_routers_allocation_liability).to eq(26)
      end
    end
  end
end
