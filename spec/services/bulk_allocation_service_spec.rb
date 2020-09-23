require 'rails_helper'

RSpec.describe BulkAllocationService do
  let(:schools) { create_list(:school, 3, :with_std_device_allocation, order_state: 'cannot_order') }

  subject(:service) { described_class.new }

  describe '#unlock!' do
    let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest, timestamp: Time.zone.now, payload_id: '123456789') }

    before do
      allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
      allow(mock_request).to receive(:post!)
    end

    it 'enables the schools to order their full allocation' do
      service.unlock!(schools.map(&:urn))
      schools.each do |school|
        school.reload
        expect(school.std_device_allocation.cap).to eq(school.std_device_allocation.allocation)
        expect(school.can_order?).to be true
      end
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
