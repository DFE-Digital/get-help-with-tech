require 'rails_helper'

RSpec.describe BulkAllocationService do
  let(:schools) { create_list(:school, 3, :with_std_device_allocation, :with_coms_device_allocation, order_state: 'cannot_order') }

  subject(:service) { described_class.new }

  describe '#unlock!' do
    before do
      @computacenter_api_call = stub_computacenter_outgoing_api_calls
    end

    it 'enables the schools to order their full allocation' do
      service.unlock!(schools.map(&:urn))
      schools.each do |school|
        school.reload
        expect(school.std_device_allocation.cap).to eq(school.std_device_allocation.allocation)
        expect(school.coms_device_allocation.cap).to eq(school.coms_device_allocation.allocation)
        expect(school.can_order?).to be true
      end
      expect(@computacenter_api_call).to have_been_requested.times(6)
    end

    it 'keeps track of successes and failures' do
      service.unlock!(schools.map(&:urn).append('32ew'))
      expect(service.success_count).to eq(schools.count)
      expect(service.failure_count).to eq(1)
      expect(service.success.map { |s| s[:urn] }).to eq(schools.map(&:urn))
      expect(service.failures).to eq [{ urn: '32ew', message: 'URN not found' }]
    end
  end
end
