require 'rails_helper'

RSpec.feature 'Show debug info feature flag', type: :feature do
  context 'with the show_debug_info feature flag active' do
    before do
      FeatureFlag.activate(:show_debug_info)
      visit '/'
    end

    it 'renders the session into the footer' do
      within('footer') { expect(page).to have_content 'Session' }
    end
  end

  context 'with the show_debug_info feature flag inactive' do
    before do
      FeatureFlag.deactivate(:show_debug_info)
      visit '/'
    end

    it 'does not render the session into the footer' do
      within('footer') { expect(page).not_to have_content 'Session' }
    end
  end
end
