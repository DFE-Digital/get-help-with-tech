require 'rails_helper'

RSpec.describe DisplayDevicesOrderedComponent, type: :component do
  let(:trust) { create(:trust, :manages_centrally, :vcap_feature_flag) }
  let(:school) { create(:school, :manages_orders, responsible_body: trust, laptops: [1, 0, 0], routers: [1, 0, 0]) }
  let(:another_school) { create(:school, :manages_orders, responsible_body: trust, laptops: [1, 0, 0], routers: [1, 0, 0]) }

  subject(:component) { described_class.new(school: school) }

  before do
    stub_computacenter_outgoing_api_calls
    school.update!(raw_laptops_ordered: 24)
    school.update!(raw_routers_ordered: 33)
    SchoolSetWhoManagesOrdersService.new(another_school, :responsible_body).call
  end

  context 'when in a virtual pool' do
    before do
      SchoolSetWhoManagesOrdersService.new(school, :responsible_body).call
      school.reload
    end

    it 'renders the devices ordered' do
      render_inline(component)
      expect(rendered_component).to include('24&nbsp;devices')
      expect(rendered_component).to include('33&nbsp;routers')
    end
  end

  context 'when not in a virtual pool' do
    before do
      trust.update!(vcap_feature_flag: false)
    end

    it 'renders the devices ordered' do
      render_inline(component)
      expect(rendered_component).to include('24&nbsp;devices')
      expect(rendered_component).to include('33&nbsp;routers')
    end
  end
end
