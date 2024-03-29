require 'rails_helper'

RSpec.describe 'support/users/show.html.erb' do
  let(:support_user) { create(:support_user) }
  let(:computacenter_user) { create(:computacenter_user, is_support: true) }
  let(:user) { create(:school_user) }

  around do |example|
    without_partial_double_verification { example.run }
  end

  context 'when computacenter user' do
    before do
      allow(view).to receive(:current_user).and_return(computacenter_user)
      assign(:current_user, computacenter_user)
      assign(:user, user)
    end

    it 'does not show impersonate button' do
      render
      expect(rendered).not_to have_button('Impersonate user')
    end
  end

  context 'when support user' do
    before do
      allow(view).to receive(:current_user).and_return(support_user)
      assign(:current_user, support_user)
      assign(:user, user)
    end

    it 'shows impersonate button' do
      render
      expect(rendered).to have_button('Impersonate user')
    end
  end
end
