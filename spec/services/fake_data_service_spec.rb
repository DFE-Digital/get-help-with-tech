require 'rails_helper'

RSpec.describe FakeDataService, type: :model do
  let(:mobile_network) { create(:mobile_network) }
  let(:responsible_body) { create(:local_authority) }

  let(:fake_data_call) { FakeDataService.generate!(extra_mobile_data_requests: 3, mobile_network_id: mobile_network.id, responsible_body_id: responsible_body.id) }

  it 'creates the requested number of extra mobile data requests' do
    expect { fake_data_call }.to change { ExtraMobileDataRequest.count }.from(0).to(3)
  end

  it 'creates all requests against the passed network ID' do
    fake_data_call

    expect(ExtraMobileDataRequest.distinct.pluck(:mobile_network_id)).to eq([mobile_network.id])
  end
end
