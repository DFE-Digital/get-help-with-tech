require 'rails_helper'

RSpec.describe 'support/schools/show.html.erb' do
  let(:school) { create(:school, :with_std_device_allocation, increased_allocations_feature_flag: true) }
  let(:support_user) { create(:support_user) }

  before do
    enable_pundit(view, support_user)
    assign(:school, school)
    assign(:current_user, support_user)
  end

  describe 'banners' do
    context 'when feature flags disabled' do
      it 'does not show banners' do
        render
        expect(rendered).not_to include('Your allocation has increased to')
      end
    end

    context 'when feature flags enabled', with_feature_flags: { increased_allocations_banner: 'active' } do
      it 'shows banners' do
        render
        expect(rendered).to include("Your allocation has increased to #{pluralize(school.std_device_allocation.allocation, 'device')}")
      end
    end
  end
end
