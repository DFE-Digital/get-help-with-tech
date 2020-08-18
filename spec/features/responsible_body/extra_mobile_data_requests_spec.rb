require 'rails_helper'

RSpec.feature 'Accessing the extra mobile data requests area as a responsible body user', type: :feature do
  let(:rb_user) { create(:local_authority_user) }

  before do
    sign_in_as rb_user
  end

  scenario 'the user can navigate to the manual request form from the responsible body home page' do
    click_on 'Request extra data for mobile devices'

    expect(page).to have_css('h1', text: 'Request extra mobile data')
    expect(page).to have_http_status(:ok)
    click_on 'New request'
    expect(page).to have_css('h1', text: 'How would you like to submit information?')
    choose 'Manually (entering details one at a time)'
    click_on 'Continue'
    expect(page).to have_css('h1', text: 'Who needs the extra mobile data?')
  end

  scenario 'the user can navigate to the bulk upload form from the responsible body home page' do
    click_on 'Request extra data for mobile devices'

    expect(page).to have_css('h1', text: 'Request extra mobile data')
    expect(page).to have_http_status(:ok)
    click_on 'New request'
    expect(page).to have_css('h1', text: 'How would you like to submit information?')
    choose 'Using a spreadsheet'
    click_on 'Continue'
    expect(page).to have_css('h1', text: 'Upload a spreadsheet of extra data requests')
  end

  context 'when the user has already submitted requests' do
    let(:another_user_from_the_same_rb) { create(:user, responsible_body: rb_user.responsible_body) }

    before do
      @requests = create_list(:extra_mobile_data_request, 5, status: 'requested', created_by_user: rb_user)
      @requests.last.unavailable!
    end

    scenario 'the user can see their previous requests' do
      visit responsible_body_internet_mobile_extra_data_requests_path

      expect(page).to have_css('h2', text: 'Your requests')

      @requests.each do |request|
        expect(page).to have_content(request.device_phone_number)
        expect(page).to have_content(request.account_holder_name)
      end
      expect(page).to have_text('Requested').exactly(4).times
      expect(page).to have_text('Unavailable').once
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
  end
end
