require 'rails_helper'

RSpec.describe DisplayAllocationComponent, type: :component do
  let(:trust) { create(:trust, :manages_centrally, :vcap) }
  let(:school) { create(:school, :manages_orders, responsible_body: trust, laptops: [1, 0, 0], routers: [1, 0, 0]) }
  let(:another_school) { create(:school, :manages_orders, responsible_body: trust, laptops: [1, 0, 0], routers: [1, 0, 0]) }

  subject(:component) { described_class.new(school: school) }

  before do
    stub_computacenter_outgoing_api_calls
    UpdateSchoolDevicesService.new(school: school, laptop_allocation: 24, router_allocation: 33).call
    SchoolSetWhoManagesOrdersService.new(another_school, :responsible_body).call
  end

  context 'when in a virtual pool' do
    before do
      SchoolSetWhoManagesOrdersService.new(school, :responsible_body).call
    end

    it 'renders the pool allocation' do
      render_inline(component)
      expect(rendered_component).to include('25&nbsp;devices')
      expect(rendered_component).to include('34&nbsp;routers')
    end
  end

  context 'when not in a virtual pool' do
    before do
      trust.update!(vcap: false)
    end

    it 'renders the school allocation' do
      render_inline(component)
      expect(rendered_component).to include('24&nbsp;devices')
      expect(rendered_component).to include('33&nbsp;routers')
    end
  end
end