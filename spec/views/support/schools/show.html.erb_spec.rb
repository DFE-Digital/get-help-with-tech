require 'rails_helper'

RSpec.describe 'support/schools/show.html.erb' do
  let(:school) { create(:school, :with_std_device_allocation, increased_allocations_feature_flag: true) }
  let(:support_user) { create(:support_user) }

  before do
    enable_pundit(view, support_user)
    assign(:school, school)
    assign(:current_user, support_user)
    assign(:timeline, Timeline::School.new(school: school))
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

  describe 'when school#can_invite_users? is true' do
    it 'shows Invite a new user button' do
      allow(school).to receive(:can_invite_users?).and_return(true)

      render
      expect(rendered).to include('Invite a new user')
    end
  end

  describe 'when school#can_invite_users? is false' do
    it 'does not show Invite a new user button' do
      allow(school).to receive(:can_invite_users?).and_return(false)

      render
      expect(rendered).not_to include('Invite a new user')
    end
  end
end
