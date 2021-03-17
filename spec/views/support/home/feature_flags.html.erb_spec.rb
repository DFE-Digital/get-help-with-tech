require 'rails_helper'

RSpec.describe 'support/home/feature_flags.html.erb' do
  let(:page) { PageObjects::Support::Home::FeatureFlagsPage.new }

  it 'show feature flags statuses', with_feature_flags: { rate_limiting: 'active' } do
    render
    page.load(rendered)

    expect(page.table['rate_limiting'].status).to eql('Active')
    expect(page.table['display_sign_in_token_links'].status).to eql('Not active')
  end
end
