require 'rails_helper'

RSpec.describe DisplayAllocationsComponent, type: :component do
  let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest, timestamp: Time.zone.now, payload_id: '123456789', body: '<xml>test-request</xml>') }
  let(:response) { OpenStruct.new(body: '<xml>test-response</xml>') }

  let(:trust) { create(:trust, :manages_centrally, :vcap_feature_flag) }
  let(:school) { create(:school, :with_preorder_information, :with_std_device_allocation, :with_coms_device_allocation, responsible_body: trust) }
  let(:another_school) { create(:school, :with_preorder_information, :with_std_device_allocation, :with_coms_device_allocation, responsible_body: trust) }

  subject(:component) { described_class.new(school: school) }

  before do
    allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
    allow(mock_request).to receive(:post!).and_return(response)
    school.std_device_allocation.update!(allocation: 24)
    school.coms_device_allocation.update!(allocation: 33)
    put_school_in_pool(trust, another_school)
  end

  context 'when in a virtual pool', with_feature_flags: { virtual_caps: 'active' } do
    before do
      put_school_in_pool(trust, school)
      school.reload
    end

    it 'renders the original device allocations' do
      render_inline(component)
      expect(rendered_component).to include('24&nbsp;devices')
      expect(rendered_component).to include('33&nbsp;routers')
    end
  end

  context 'when not in a virtual pool', with_feature_flags: { virtual_caps: 'inactive' } do
    before do
      trust.update!(vcap_feature_flag: false)
    end

    it 'renders the original device allocations' do
      render_inline(component)
      expect(rendered_component).to include('24&nbsp;devices')
      expect(rendered_component).to include('33&nbsp;routers')
    end
  end

  def put_school_in_pool(responsible_body, pool_school)
    pool_school.preorder_information.responsible_body_will_order_devices!
    pool_school.can_order!
    responsible_body.add_school_to_virtual_cap_pools!(pool_school)
  end
end
