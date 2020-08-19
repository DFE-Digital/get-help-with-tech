require 'rails_helper'

RSpec.feature ResponsibleBody do
  let(:sign_in_page) { PageObjects::SignInPage.new }
  let(:responsible_body_home_page) { PageObjects::ResponsibleBody::HomePage.new }

  let(:rb_user) { create(:local_authority_user) }
  let(:mno_user) { create(:mno_user) }
  let(:responsible_body) { rb_user.responsible_body }

  context 'not signed-in' do
    scenario 'visiting the page redirects to sign-in' do
      visit responsible_body_home_path

      expect(sign_in_page).to be_displayed
    end
  end

  context 'signed in as non-RB user' do
    before do
      sign_in_as mno_user
    end

    scenario 'visiting the page shows a :forbidden error' do
      visit responsible_body_home_path

      expect(page).to have_content("You're not allowed to do that")
      expect(page).to have_http_status(:forbidden)
    end
  end

  context 'visiting the RB home page signed in as an RB user' do
    before do
      sign_in_as rb_user
      visit responsible_body_home_path
    end

    context 'with the in_connectivity_pilot flag set' do
      before do
        rb_user.responsible_body.update(in_connectivity_pilot: true)
      end

      it 'shows link to get extra data' do
        visit responsible_body_home_path

        expect(responsible_body_home_page).to be_displayed
        expect(page.status_code).to eq 200
        expect(page).to have_link('Get the internet')
      end
    end

    context 'with the in_connectivity_pilot flag not set' do
      before do
        rb_user.responsible_body.update(in_connectivity_pilot: false)
      end

      it 'does not show link to get extra data' do
        visit responsible_body_home_path

        expect(responsible_body_home_page).to be_displayed
        expect(page.status_code).to eq 200
        expect(page).not_to have_link('Get the internet')
      end
    end

    context 'with the in_devices_pilot flag set' do
      before do
        rb_user.responsible_body.update(in_devices_pilot: true)
      end

      it 'shows link to get devices' do
        visit responsible_body_home_path

        expect(responsible_body_home_page).to be_displayed
        expect(page.status_code).to eq 200
        expect(page).to have_link('Get devices')
      end
    end

    context 'with the in_devices_pilot flag not set' do
      before do
        rb_user.responsible_body.update(in_devices_pilot: false)
      end

      it 'does not show link to get devices' do
        visit responsible_body_home_path

        expect(responsible_body_home_page).to be_displayed
        expect(page.status_code).to eq 200
        expect(page).not_to have_link('Get devices')
      end
    end

    context 'when the RB is a local authority' do
      it 'shows link to Manage local authority users' do
        visit responsible_body_home_path

        expect(responsible_body_home_page).to be_displayed
        expect(page.status_code).to eq 200
        expect(page).to have_link('Manage local authority users')
      end
    end

    context 'when the RB is a trust' do
      let(:rb_user) { create(:trust_user) }
      
      it 'shows link to Manage trust users' do
        visit responsible_body_home_path

        expect(responsible_body_home_page).to be_displayed
        expect(page.status_code).to eq 200
        expect(page).to have_link('Manage trust users')
      end
    end
  end
end
