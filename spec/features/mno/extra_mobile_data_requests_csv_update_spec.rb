require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'Update MNO Requests via CSV', type: :feature do
  let(:mno_user) { create(:mno_user) }
  let(:local_authority_user) { create(:local_authority_user) }

  scenario 'navigating to the CSV update page' do
    given_i_have_some_mobile_data_requests
    given_i_am_signed_in_as_a_mno_user
    when_i_follow_the_csv_update_link
    then_i_see_a_form_to_upload_a_csv_file
  end

  def given_i_am_signed_in_as_a_mno_user
    sign_in_as mno_user
  end

  def given_i_have_some_mobile_data_requests
    create_list(:extra_mobile_data_request, 2, mobile_network: mno_user.mobile_network, created_by_user: local_authority_user)
  end

  def when_i_follow_the_csv_update_link
    click_on 'Update requests using a CSV'
  end

  def then_i_see_a_form_to_upload_a_csv_file
    expect(page).to have_selector('h1', text: 'Update requests using a CSV')
    expect(page).to have_field('CSV file')
  end
end
