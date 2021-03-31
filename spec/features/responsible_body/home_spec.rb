require 'rails_helper'

RSpec.feature ResponsibleBody do
  let(:sign_in_page) { PageObjects::SignInPage.new }
  let(:responsible_body_home_page) { PageObjects::ResponsibleBody::HomePage.new }

  let(:responsible_body) { create(:local_authority) }
  let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body) }
  let(:mno_user) { create(:mno_user) }

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

      expect(page).to have_content('You’re not allowed to do that')
      expect(page).to have_http_status(:forbidden)
    end
  end

  context 'visiting the RB home page signed in as an RB user' do
    before do
      sign_in_as rb_user
      visit responsible_body_home_path
    end

    it 'shows link to get laptops and tablets' do
      visit responsible_body_home_path

      expect(responsible_body_home_page).to be_displayed
      expect(page.status_code).to eq 200
      expect(page).to have_link('Get laptops and tablets')
    end

    context 'with a responsible body managing at least 1 school centrally' do
      let(:schools) { create_list(:school, 4, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }

      before do
        schools[0].preorder_information.responsible_body_will_order_devices!
      end

      it 'shows link to get extra data' do
        visit responsible_body_home_path
        expect(page).to have_link('Get internet access')
      end
    end

    context 'with a trust devolved to all schools' do
      let(:responsible_body) { create(:trust) }

      it 'does not show link to get extra data' do
        visit responsible_body_home_path
        expect(page).not_to have_link('Get internet access')
      end
    end

    context 'with a local authority devolved to all schools' do
      it 'shows link to get extra data' do
        visit responsible_body_home_path
        expect(page).to have_link('Get internet access')
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

      it 'shows link to Manage trust administrators' do
        visit responsible_body_home_path

        expect(responsible_body_home_page).to be_displayed
        expect(page.status_code).to eq 200
        expect(page).to have_link('Manage trust administrators')
      end
    end
  end

  context 'as a first-time RB user' do
    let(:rb_user) { create(:local_authority_user, privacy_notice_seen_at: nil) }

    it 'shows the privacy notice for the first time' do
      sign_in_as rb_user
      expect(page).to have_content('How we look after personal information as part of the Get help with technology programme')

      click_on 'Continue'
      expect(responsible_body_home_page).to be_displayed

      sign_out
      sign_in_as rb_user
      expect(responsible_body_home_page).to be_displayed
    end
  end
end
