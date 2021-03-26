require 'rails_helper'
require 'shared/filling_in_forms'

RSpec.feature 'Submitting an extra mobile data request', type: :feature do
  context 'not signed in' do
    it 'does not show the link in the nav' do
      visit '/'
      expect(page).not_to have_text('Tell us who needs more data')
    end

    scenario 'visiting the form directly should redirect to sign_in' do
      visit new_responsible_body_internet_mobile_manual_request_path
      expect(page).to have_current_path(sign_in_path)
    end
  end

  context 'signed in' do
    let(:responsible_body) { create(:local_authority) }
    let(:user) { create(:local_authority_user, responsible_body: responsible_body) }
    let(:mobile_network) { create(:mobile_network) }
    let(:school) { create(:school, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }

    before do
      school.preorder_information.responsible_body_will_order_devices!

      mobile_network
      sign_in_as user
      # prevent api call to Notify
      stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/sms')
        .to_return(status: 201, body: '{}')
    end

    scenario 'Navigating to the form' do
      visit responsible_body_home_path
      click_on('Internet access')
      click_on('Request extra data for mobile devices')
      click_on('New request')
      expect(page).to have_text('How would you like to submit information?')
      choose('One at a time, using a form')
      click_on('Continue')
      expect(page).to have_text('Who needs the extra mobile data?')
    end

    scenario 'submitting the form with invalid params shows errors' do
      visit new_responsible_body_internet_mobile_manual_request_path
      fill_in 'Mobile phone number', with: '-1'
      click_on 'Continue'
      expect(page.status_code).not_to eq(200)
      expect(page).to have_text('There is a problem')
    end

    context 'when the mno is participating' do
      scenario 'submitting the form with valid params goes to confirmation page' do
        visit new_responsible_body_internet_mobile_manual_request_path
        fill_in_valid_application_form(mobile_network_name: mobile_network.brand)
        click_on 'Continue'

        expect(page.status_code).to eq(200)
        expect(page).to have_text('Anne Account-Holder')
        expect(page).to have_text('07123456780')
        expect(page).to have_text(mobile_network.brand)
        expect(page).to have_text('Pay as you go (PAYG)')
        expect(page).to have_text('Check your answers')
        expect(page).to have_text("These details will be passed to #{mobile_network.brand}")
      end
    end

    context 'when the mno is not particpating' do
      let(:mobile_network) { create(:mobile_network, :maybe_participating_in_pilot) }

      scenario 'only participating networks are available for selection' do
        visit new_responsible_body_internet_mobile_manual_request_path
        expect(page).not_to have_field(mobile_network.brand)
      end
    end

    scenario 'clicking Change on the confirmation page populates the form again' do
      visit new_responsible_body_internet_mobile_manual_request_path
      fill_in_valid_application_form(mobile_network_name: mobile_network.brand)
      fill_in 'Account holder name', with: 'My new account holder name'
      click_on 'Continue'

      expect(page.status_code).to eq(200)

      within('#account-holder-name') do
        click_link 'Change'
      end

      expect(find_field('Account holder name').value).to eq('My new account holder name')
      expect(find_field('Mobile phone number').value).to eq('07123456780')
      expect(page).to have_checked_field(mobile_network.brand)
      expect(page).to have_checked_field('Pay as you go (PAYG)')
      expect(page).to have_checked_field('Yes, the privacy statement has been shared')
    end

    scenario 'confirming a form works' do
      visit new_responsible_body_internet_mobile_manual_request_path
      fill_in_valid_application_form(mobile_network_name: mobile_network.brand)
      fill_in 'Account holder name', with: 'My confirmed account holder name'

      click_on 'Continue'

      expect(page.status_code).to eq(200)
      expect(page).to have_text('Check your answers')

      click_on 'Confirm request'
      expect(page).to have_text('Your request has been received')
      expect(page).to have_text('My confirmed account holder name')
    end
  end
end
