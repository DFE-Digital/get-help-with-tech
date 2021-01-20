require 'rails_helper'

RSpec.feature 'Accessing the extra mobile data requests area as a school user', type: :feature do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  before do
    sign_in_as user
  end

  scenario 'the user can navigate to the manual request form from the home page' do
    click_on 'Get internet access'
    click_on 'Request extra data for mobile devices'

    expect(page).to have_css('h1', text: 'Request extra data for mobile devices')
    expect(page).to have_http_status(:ok)
    click_on 'New request'
    expect(page).to have_css('h1', text: 'How would you like to submit information?')
    choose 'Manually (entering details one at a time)'
    click_on 'Continue'
    expect(page).to have_css('h1', text: 'Who needs the extra mobile data?')
  end

  scenario 'the user can navigate to the bulk upload form from the home page' do
    click_on 'Get internet access'
    click_on 'Request extra data for mobile devices'

    expect(page).to have_css('h1', text: 'Request extra data for mobile devices')
    expect(page).to have_http_status(:ok)
    click_on 'New request'
    expect(page).to have_css('h1', text: 'How would you like to submit information?')
    choose 'Using a spreadsheet'
    click_on 'Continue'
    expect(page).to have_css('h1', text: 'Upload a spreadsheet of extra data requests')
  end

  context 'when the user has already submitted requests' do
    let(:another_user_from_the_same_school) { create(:school_user, school: school) }

    before do
      @requests = create_list(:extra_mobile_data_request, 5, status: 'requested', created_by_user: user, school: school)
      @requests.last.unavailable_status!
    end

    scenario 'the user can navigate to their previous requests from the home page' do
      click_on 'Get internet access'
      click_on 'Request extra data for mobile devices'

      expect(page).to have_css('h1', text: 'Request extra data for mobile devices')
      expect(page).to have_http_status(:ok)

      click_on 'Check your requests'

      expect(page).to have_css('h1', text: 'Your requests')
      expect(page).to have_http_status(:ok)
    end

    scenario 'the user can see their previous requests' do
      visit extra_data_requests_internet_mobile_school_path(school)

      expect(page).to have_css('h1', text: 'Your requests')

      @requests.each do |request|
        expect(page).to have_content(request.device_phone_number)
        expect(page).to have_content(request.account_holder_name)
      end
      expect(page).to have_text('Requested').exactly(4).times
      expect(page).to have_text('Unavailable').once
    end

    scenario 'another user from the same school can also see the raised requests' do
      sign_out
      sign_in_as another_user_from_the_same_school

      visit extra_data_requests_internet_mobile_school_path(school)

      @requests.each do |request|
        expect(page).to have_content(request.device_phone_number)
        expect(page).to have_content(request.account_holder_name)
      end
    end
  end
end
