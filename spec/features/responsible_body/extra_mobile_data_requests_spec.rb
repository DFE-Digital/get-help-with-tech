require 'rails_helper'

RSpec.feature 'Accessing the extra mobile data requests area as a responsible body user', type: :feature do
  let(:responsible_body) { create(:local_authority) }
  let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body) }
  let(:mobile_network) { create(:mobile_network) }
  let(:school) { create(:school, :with_std_device_allocation, :with_preorder_information, responsible_body: responsible_body) }
  let(:my_requests_page) { PageObjects::School::Internet::YourRequestsPage.new }

  before do
    school.preorder_information.responsible_body_will_order_devices!
    responsible_body.update!(in_connectivity_pilot: true)
    sign_in_as rb_user
  end

  scenario 'the user can navigate to the manual request form from the responsible body home page' do
    click_on 'Get internet access'
    click_on 'Request extra data for mobile devices'

    expect(page).to have_css('h1', text: 'Request extra data for mobile devices')
    expect(page).to have_http_status(:ok)
    click_on 'New request'
    expect(page).to have_css('h1', text: 'How would you like to submit information?')
    choose 'One at a time, using a form'
    click_on 'Continue'
    expect(page).to have_css('h1', text: 'Who needs the extra mobile data?')
  end

  scenario 'the user can navigate to the bulk upload form from the responsible body home page' do
    click_on 'Get internet access'
    click_on 'Request extra data for mobile devices'

    expect(page).to have_css('h1', text: 'Request extra data for mobile devices')
    expect(page).to have_http_status(:ok)
    click_on 'New request'
    expect(page).to have_css('h1', text: 'How would you like to submit information?')
    choose 'Many at once, using a spreadsheet'
    click_on 'Continue'
    expect(page).to have_css('h1', text: 'Upload a spreadsheet of extra data requests')
  end

  context 'when the user has already submitted requests' do
    let(:another_user_from_the_same_rb) { create(:user, responsible_body: responsible_body) }

    before do
      @requests = create_list(:extra_mobile_data_request, 5, status: 'new', created_by_user: rb_user)
      @requests.last.unavailable_status!
    end

    scenario 'the user can see their previous requests' do
      visit responsible_body_internet_mobile_extra_data_requests_path

      expect(my_requests_page.heading.text).to eq('Your requests')

      @requests.each do |request|
        request_row = my_requests_page.row_for(request)
        expect(request_row).not_to be_nil
        expect(request_row).to have_content(request.id)
        expect(request_row).to have_content(request.device_phone_number)
        expect(request_row).to have_content(request.account_holder_name)
        expect(request_row).to have_content(request.created_at.to_date.to_s(:long_ordinal))
      end

      within my_requests_page.requests_table do
        expect(page).to have_text('Requested').exactly(5).times
        expect(page).to have_text('Unavailable').once
      end
    end

    scenario 'another user from the same responsible body can also see the raised requests' do
      sign_out
      sign_in_as another_user_from_the_same_rb

      visit responsible_body_internet_mobile_extra_data_requests_path

      @requests.each do |request|
        expect(page).to have_content(request.device_phone_number)
        expect(page).to have_content(request.account_holder_name)
      end
    end

    context 'when there are more requests that the per-page limit' do
      around do |example|
        original_pagination_value = Pagy::VARS[:items]
        Pagy::VARS[:items] = 2
        example.run
        Pagy::VARS[:items] = original_pagination_value
      end

      scenario 'user can navigate between pages' do
        visit responsible_body_internet_mobile_extra_data_requests_path
        expect(page).to have_content('Next page')
        expect(page).to have_content('2 of 3')

        click_on 'Next page'

        expect(page).to have_content('Next page')
        expect(page).to have_content('1 of 3')
        expect(page).to have_content('Previous page')
        expect(page).to have_content('3 of 3')
      end
    end

    context 'when the user clicks on a requests account_holder_name' do
      let(:mno_without_view_template) { MobileNetwork.find_or_create_by(brand: 'Some Unknown Mobile', participation_in_pilot: 'participating') }
      let(:mno_with_view_template) { MobileNetwork.find_or_create_by(brand: 'BT Mobile', participation_in_pilot: 'participating') }
      let(:status) { 'new' }
      let!(:request) { create(:extra_mobile_data_request, status: status, created_by_user: rb_user, responsible_body: responsible_body, mobile_network: mno_with_view_template, device_phone_number: '07123 123456') }

      before do
        visit responsible_body_internet_mobile_extra_data_requests_path
        click_on request.account_holder_name
      end

      it 'has a non-personally-identifying title' do
        expect(page.title).to eq('BT Mobile request 07...3456 - Get help with technology - GOV.UK')
      end

      it 'shows the request details' do
        expect(page).to have_css 'h1', text: request.account_holder_name
        expect(page).to have_content 'Request details'
      end

      it 'shows the request ID' do
        expect(page).to have_content 'Request ID'
        expect(page).to have_content request.id
      end

      context 'when the request has a mobile network with an offer details partial template' do
        it 'shows the offer details for the correct mobile network' do
          expect(page).to have_content "#{request.mobile_network.brand} offer"
        end
      end

      context 'when the request is for a mobile network which does not have an offer details partial template' do
        let(:request) { create(:extra_mobile_data_request, status: 'new', created_by_user: rb_user, responsible_body: responsible_body, mobile_network: mno_without_view_template) }

        it 'does not show offer details' do
          expect(page).not_to have_content "#{request.mobile_network.brand} offer"
        end
      end

      context 'when the request is complete' do
        let(:status) { 'complete' }

        it 'shows status complete' do
          expect(page).to have_css('#request-status', text: 'Complete')
        end
      end

      context 'when the request is problem_no_match_for_number' do
        let(:status) { 'problem_no_match_for_number' }

        it 'shows status unknown number' do
          expect(page).to have_css('#request-status', text: 'Unknown number')
        end

        it 'shows a panel with more info about the problem' do
          expect(page).to have_content("#{request.mobile_network.brand} did not recognise this number")
          expect(page).to have_content('Check the following')
          expect(page).to have_content('the number was typed correctly')
          expect(page).to have_content('the correct mobile network was provided')
          expect(page).to have_link('Make new request')
        end
      end

      context 'when the request is problem_incorrect_phone_number' do
        let(:status) { 'problem_incorrect_phone_number' }

        it 'shows status invalid number' do
          expect(page).to have_css('#request-status', text: 'Invalid number')
        end

        it 'shows a panel with more info about the problem' do
          expect(page).to have_content("#{request.mobile_network.brand} did not recognise this number")
          expect(page).to have_content('Check the following')
          expect(page).to have_content('the number was typed correctly')
          expect(page).to have_content('the correct mobile network was provided')
          expect(page).to have_link('Make new request')
        end
      end

      context 'when the request is problem_no_match_for_account_name' do
        let(:status) { 'problem_no_match_for_account_name' }

        it 'shows status unknown name' do
          expect(page).to have_css('#request-status', text: 'Unknown name')
        end

        it 'shows a panel with more info about the problem' do
          expect(page).to have_content("#{request.mobile_network.brand} did not recognise this name")
          expect(page).to have_content('Check the following')
          expect(page).to have_content('the correct account holder was given')
          expect(page).to have_content('the name matches the name on the bill')
          expect(page).to have_link('Make new request')
        end
      end

      context 'when the request is problem_not_eligible' do
        let(:status) { 'problem_not_eligible' }

        it 'shows status not eligible' do
          expect(page).to have_css('#request-status', text: 'Not eligible')
        end

        it 'shows a panel with more info about the problem' do
          expect(page).to have_content("#{request.mobile_network.brand} told us this account is not eligible")
          expect(page).to have_content("they are a new #{request.mobile_network.brand} customer")
          expect(page).to have_content("they do not meet #{request.mobile_network.brand}’s criteria")
          expect(page).to have_content('they already have fixed line broadband at home')
          expect(page).to have_link('4G wireless router instead')
        end
      end

      context 'when the request is problem_duplicate' do
        let(:status) { 'problem_duplicate' }

        it 'shows status duplicate' do
          expect(page).to have_css('#request-status', text: 'Duplicate request')
        end

        it 'shows a panel with more info about the problem' do
          expect(page).to have_content("#{request.mobile_network.brand} told us this is a duplicate request")
          expect(page).to have_content('the correct account holder was given')
          expect(page).to have_content('the number was typed correctly')
          expect(page).to have_content('the correct mobile network was provided')
        end
      end

      context 'when the request is problem_other' do
        let(:status) { 'problem_other' }

        it 'shows status other problem' do
          expect(page).to have_css('#request-status', text: 'Other problem')
        end

        it 'shows a panel with more info about the problem' do
          expect(page).to have_content("#{request.mobile_network.brand} could not process this request")
          expect(page).to have_content('They did not give a reason why')
          expect(page).to have_link('4G wireless router instead')
        end
      end

      context 'when the request is unavailable' do
        let(:status) { 'unavailable' }

        it 'shows status other problem' do
          expect(page).to have_css('#request-status', text: 'Unavailable')
        end

        it 'shows a panel with more info about the problem' do
          expect(page).to have_content("#{request.mobile_network.brand} is not offering data increases yet")
          expect(page).to have_content('We cannot request an increase in data from a network that’s not participating in the offer.')
        end
      end
    end
  end
end
