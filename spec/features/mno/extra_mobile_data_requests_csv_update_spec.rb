require 'rails_helper'
require 'shared/expect_download'

RSpec.describe 'Update MNO Requests via CSV', type: :feature do
  let(:mno_user) { create(:mno_user) }
  let(:local_authority_user) { create(:local_authority_user) }
  let(:filename) { Rails.root.join('tmp/update_status.csv') }
  let(:invalid_filename) { Rails.root.join('tmp/update_status.doc') }

  it 'navigating to the CSV update page' do
    given_i_have_some_mobile_data_requests
    given_i_am_signed_in_as_a_mno_user
    when_i_follow_the_csv_update_link
    then_i_see_a_form_to_upload_a_csv_file
  end

  it 'submitting a CSV with status updates' do
    given_i_have_some_mobile_data_requests
    given_i_am_signed_in_as_a_mno_user
    when_i_visit_the_csv_update_page
    and_i_select_my_csv_file
    and_i_click_the_upload_and_update_requests_button
    then_i_see_a_summary_page
  end

  it 'submitting more that 50 updates' do
    given_i_have_more_than_50_mobile_data_requests
    given_i_am_signed_in_as_a_mno_user
    when_i_visit_the_csv_update_page
    and_i_select_my_large_csv_file
    and_i_click_the_upload_and_update_requests_button
    then_i_see_a_summary_page_with_the_first_50_of_my_updates
  end

  it 'submitting more that 50 updates with errors' do
    given_i_have_more_than_50_mobile_data_requests
    given_i_am_signed_in_as_a_mno_user
    when_i_visit_the_csv_update_page
    and_i_select_my_large_csv_file_with_errors
    and_i_click_the_upload_and_update_requests_button
    then_i_see_a_summary_page_with_the_first_50_errors_displayed
  end

  it 'submitting an invalid file' do
    given_i_have_some_mobile_data_requests
    given_i_am_signed_in_as_a_mno_user
    when_i_visit_the_csv_update_page
    and_i_select_an_invalid_file
    and_i_click_the_upload_and_update_requests_button
    then_i_see_an_invalid_error
  end

  def given_i_am_signed_in_as_a_mno_user
    sign_in_as mno_user
  end

  def given_i_have_some_mobile_data_requests
    @requests = create_list(:extra_mobile_data_request, 2, mobile_network: mno_user.mobile_network, created_by_user: local_authority_user)
  end

  def given_i_have_more_than_50_mobile_data_requests
    @requests = create_list(:extra_mobile_data_request, 52, mobile_network: mno_user.mobile_network, created_by_user: local_authority_user)
  end

  def when_i_follow_the_csv_update_link
    click_on 'Update requests using a CSV'
  end

  def when_i_visit_the_csv_update_page
    visit new_mno_extra_mobile_data_requests_csv_update_path
  end

  def and_i_select_my_csv_file
    attrs = requests_to_attrs
    attrs[0][:status] = 'in_progress'
    attrs[1][:status] = 'problem_no_match_for_number'

    create_extra_mobile_data_request_update_csv_file(filename, attrs)
    attach_file('CSV file', filename)
  end

  def and_i_select_my_large_csv_file
    attrs = requests_to_attrs
    attrs.each { |req| req[:status] = 'in_progress' }

    create_extra_mobile_data_request_update_csv_file(filename, attrs)
    attach_file('CSV file', filename)
  end

  def and_i_select_my_large_csv_file_with_errors
    attrs = requests_to_attrs
    attrs.each { |req| req[:status] = 'an_error' }

    create_extra_mobile_data_request_update_csv_file(filename, attrs)
    attach_file('CSV file', filename)
  end

  def and_i_select_an_invalid_file
    File.write(invalid_filename, 'test')
    attach_file('CSV file', invalid_filename)
  end

  def then_i_see_an_invalid_error
    expect(page).to have_text('Choose a CSV file')
    remove_file(invalid_filename)
  end

  def and_i_click_the_upload_and_update_requests_button
    click_on 'Upload and update requests'
  end

  def then_i_see_a_form_to_upload_a_csv_file
    expect(page).to have_selector('h1', text: 'Update requests using a CSV')
    expect(page).to have_field('CSV file')
  end

  def then_i_see_a_summary_page
    expect(page).to have_selector('h1', text: 'We’ve processed your CSV')
    expect(page).to have_text('0 were not changed')
    expect(page).to have_text('0 contain errors')
    expect(page).to have_text('2 were updated successfully')

    row0 = "#{@requests[0].id} #{@requests[0].account_holder_name} #{@requests[0].device_phone_number} In progress"
    row1 = "#{@requests[1].id} #{@requests[1].account_holder_name} #{@requests[1].device_phone_number} Unknown number"
    expect(page).to have_selector('tr', text: row0)
    expect(page).to have_selector('tr', text: row1)

    remove_file(filename)
  end

  def then_i_see_a_summary_page_with_the_first_50_of_my_updates
    expect(page).to have_selector('h1', text: 'We’ve processed your CSV')
    expect(page).to have_text('0 were not changed')
    expect(page).to have_text('0 contain errors')
    expect(page).to have_text('52 were updated successfully')
    expect(page).to have_text('Showing the first 50 of 52 updated requests')

    within('#updates-table tbody') do
      expect(all('tr').count).to eq(50)
    end

    remove_file(filename)
  end

  def then_i_see_a_summary_page_with_the_first_50_errors_displayed
    expect(page).to have_selector('h1', text: 'We’ve processed your CSV')
    expect(page).to have_text('0 were not changed')
    expect(page).to have_text('52 contain errors')
    expect(page).to have_text('0 were updated successfully')
    expect(page).to have_text('Showing the first 50 of 52 requests containing errors')

    within('#errors-table tbody') do
      expect(all('tr').count).to eq(50)
    end

    remove_file(filename)
  end

  def requests_to_attrs
    @requests.map do |req|
      {
        id: req.id,
        account_holder_name: req.account_holder_name,
        device_phone_number: req.device_phone_number,
        created_at: req.created_at,
        updated_at: req.updated_at,
        mobile_network_id: req.mobile_network_id,
        status: req.status,
        contract_type: req.contract_type,
      }
    end
  end
end
