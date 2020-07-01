require 'rails_helper'

RSpec.feature 'HTTP Basic Auth feature flag', type: :feature do
  context 'with the http_basic_auth feature flag active' do
    let(:basic_auth_user) { 'laksfjlaksjf' }
    let(:basic_auth_password) { 'jksdosijdg' }

    before do
      FeatureFlag.activate(:http_basic_auth)
      Settings.http_basic_auth.username = basic_auth_user
      Settings.http_basic_auth.password = basic_auth_password
    end

    scenario 'visiting the root url requires basic auth' do
      visit '/'
      expect(page).to have_http_status(:unauthorized)
      expect(page).not_to have_selector 'h1', text: 'Increasing internet access for vulnerable and disadvantaged children'
    end
  end

  context 'with the http_basic_auth feature flag inactive' do
    before do
      FeatureFlag.deactivate(:http_basic_auth)
    end

    scenario 'visiting the root url does not require basic auth' do
      visit '/'
      expect(page).to have_http_status(:ok)
      expect(page).to have_selector 'h1', text: 'Increasing internet access for vulnerable and disadvantaged children'
    end
  end
end
