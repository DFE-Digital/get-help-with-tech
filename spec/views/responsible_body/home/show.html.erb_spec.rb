require 'rails_helper'

RSpec.describe 'responsible_body/home/show.html.erb' do
  describe 'Christmas banner' do
    before do
      assign(:responsible_body, build(:trust))
    end

    context 'when christmas_banner feature flag disabled' do
      it 'does not render christmas banner' do
        render
        expect(rendered).not_to include('No orders over Christmas')
      end
    end

    context 'when christmas_banner feature flag enabled', with_feature_flags: { christmas_banner: 'active' } do
      it 'does renders christmas banner' do
        render
        expect(rendered).to include('No orders over Christmas')
      end
    end
  end
end
