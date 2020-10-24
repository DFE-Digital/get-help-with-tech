require 'rails_helper'

RSpec.describe Support::Internet::ServicePerformance, type: :model do
  subject(:stats) { Support::Internet::ServicePerformance.new }

  describe 'extra mobile data requests' do
    before do
      create_list(:extra_mobile_data_request, 5,
                  mobile_network: create(:mobile_network, brand: '2nd Best'), status: :requested)
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
        expect(stats.extra_mobile_data_requests_by_status).to eq(
          'requested' => 5,
          'in_progress' => 2,
          'queried' => 10,
        )
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
end
