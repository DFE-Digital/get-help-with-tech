require 'rails_helper'

describe 'Viewing the Sidekiq Admin panel' do
  let(:dfe_user) { create(:dfe_user) }
  let(:mno_user) { create(:mno_user) }
  let(:rb_user) { create(:local_authority_user) }

  context 'Logged in as a DfE user' do
    before do
      sign_in_as dfe_user
    end

    it 'responds with HTTP 200 when I click "Background jobs"' do
      click_on 'Technical support'
      click_on 'Background jobs'
      expect(page).to have_http_status(:ok)
    end
  end

  context 'logged in as an RB user' do
    before do
      sign_in_as rb_user
    end

    it 'raises a routing error when I visit the URL directly' do
      expect { visit '/support/sidekiq' }.to raise_error(ActionController::RoutingError)
    end
  end

  context 'logged in as an MNO user' do
    before do
      sign_in_as mno_user
    end

    it 'raises a routing error when I visit the URL directly' do
      expect { visit '/support/sidekiq' }.to raise_error(ActionController::RoutingError)
    end
  end
end
