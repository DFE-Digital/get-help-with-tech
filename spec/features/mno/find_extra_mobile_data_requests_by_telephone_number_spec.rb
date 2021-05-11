require 'rails_helper'
require 'shared/expect_download'

RSpec.describe 'Find MNO Requests by telephone number', type: :feature do
  let(:local_authority_user) { create(:local_authority_user) }
  let(:mno_user) { create(:mno_user) }
  let!(:extra_mobile_data_requests_for_mno) { create_list(:extra_mobile_data_request, 3, mobile_network: mno_user.mobile_network, created_by_user: local_authority_user) }

  it 'visiting Your requests' do
    given_i_am_signed_in_as_an_mno_user
    and_i_click_on_the_your_requests_link
    then_i_see_my_list_of_requests
    and_i_see_a_form_to_find_requests_by_telephone_number
  end

  it 'finding requests by telephone number' do
    given_i_am_signed_in_as_an_mno_user
    and_i_click_on_the_your_requests_link
    when_i_enter_the_phone_numbers_of_the_requests_i_want_to_find
    and_i_click_the_find_requests_button
    then_i_see_a_list_of_requests_matching_those_phone_numbers
  end

  it 'mass selecting the matching requests' do
    given_i_am_signed_in_as_an_mno_user
    and_i_click_on_the_your_requests_link
    when_i_enter_the_phone_numbers_of_the_requests_i_want_to_find
    and_i_click_the_find_requests_button
    then_i_see_a_list_of_requests_matching_those_phone_numbers

    when_i_click_on_select_all
    then_i_see_a_list_of_requests_matching_those_phone_numbers
    and_all_checkboxes_are_selected

    when_i_click_on_select_none
    then_i_see_a_list_of_requests_matching_those_phone_numbers
    and_none_of_the_checkboxes_are_selected
  end

  it 'sorting the list of matching requests' do
    given_i_am_signed_in_as_an_mno_user
    and_i_click_on_the_your_requests_link
    when_i_enter_the_phone_numbers_of_the_requests_i_want_to_find
    and_i_click_the_find_requests_button
    then_i_see_a_list_of_requests_matching_those_phone_numbers

    when_i_click_on_a_column_header
    then_i_see_a_list_of_requests_matching_those_phone_numbers
    and_sorted_by_that_column

    when_i_click_on_a_column_header_again
    then_i_see_a_list_of_requests_matching_those_phone_numbers
    and_sort_order_is_reversed
  end

  it 'updating selected matching requests' do
    given_i_am_signed_in_as_an_mno_user
    and_i_click_on_the_your_requests_link
    when_i_enter_the_phone_numbers_of_the_requests_i_want_to_find
    and_i_click_the_find_requests_button
    then_i_see_a_list_of_requests_matching_those_phone_numbers

    when_i_click_on_select_all
    and_i_select_the_in_progress_status
    and_i_click_the_update_button
    then_i_see_a_list_of_requests_matching_those_phone_numbers
    and_the_statuses_are_set_to_in_progress
  end

  def and_i_select_the_in_progress_status
    select('In progress', from: 'Set status of selected to')
  end

  def and_i_click_the_update_button
    click_on 'Update'
  end

  def and_the_statuses_are_set_to_in_progress
    expect(all('.extra_mobile_data_request-status')).to all(have_content('In progress'))
  end

  def when_i_click_on_a_column_header
    click_on 'Account holder'
  end

  def when_i_click_on_a_column_header_again
    click_on 'Account holder'
  end

  def and_sorted_by_that_column
    expect(rendered_ids).to eq(requests_to_find.sort { |r1, r2| r1.account_holder_name <=> r2.account_holder_name }.pluck(:id))
  end

  def and_sort_order_is_reversed
    expect(rendered_ids).to eq(requests_to_find.sort { |r1, r2| r2.account_holder_name <=> r1.account_holder_name }.pluck(:id))
  end

  def rendered_ids
    all('tbody tr').map { |e| e[:id].split('-').last.to_i }
  end

  def when_i_click_on_select_all
    click_on 'all'
  end

  def and_all_checkboxes_are_selected
    all('input[name="mno_extra_mobile_data_requests_form[extra_mobile_data_request_ids][]"]').each do |e|
      expect(e.checked?).to eq(true)
    end
  end

  def when_i_click_on_select_none
    click_on 'none'
  end

  def and_none_of_the_checkboxes_are_selected
    all('input[name="mno_extra_mobile_data_requests_form[extra_mobile_data_request_ids][]"]').each do |e|
      expect(e.checked?).to eq(false)
    end
  end

  def given_i_am_signed_in_as_an_mno_user
    sign_in_as mno_user
  end

  def and_i_click_on_the_your_requests_link
    click_on 'Your requests'
  end

  def then_i_see_my_list_of_requests
    expect(page).to have_content(mno_user.mobile_network.brand)
    expect(page).to have_content('Requests for extra mobile data')
    expect(page).to have_link('Download requests as CSV')
    expect(page).to have_link('Update requests using a CSV')
    expect(page).to have_content("All requests (#{extra_mobile_data_requests_for_mno.count})")

    extra_mobile_data_requests_for_mno.each do |request|
      expect(page).to have_content(request.account_holder_name)
      expect(page).to have_content(request.device_phone_number)
    end
  end

  def and_i_see_a_form_to_find_requests_by_telephone_number
    expect(page).to have_content('Find requests by telephone number')
    expect(page).to have_field('Telephone numbers')
    expect(page).to have_button('Find requests')
  end

  def when_i_enter_the_phone_numbers_of_the_requests_i_want_to_find
    phones = requests_to_find.map(&:device_phone_number).join("\r\n")

    fill_in 'Telephone numbers', with: phones
  end

  def requests_to_find
    extra_mobile_data_requests_for_mno[0..1]
  end

  def and_i_click_the_find_requests_button
    click_on 'Find requests'
  end

  def then_i_see_a_list_of_requests_matching_those_phone_numbers
    expect(page).to have_content('2 requests found')
    expect(page).to have_link('Download requests as CSV')
    expect(page).to have_link('Update requests using a CSV')

    requests_to_find.each do |request|
      expect(page).to have_content(request.account_holder_name)
      expect(page).to have_content(request.device_phone_number)
    end

    request = extra_mobile_data_requests_for_mno.last
    expect(page).not_to have_content(request.account_holder_name)
    expect(page).not_to have_content(request.device_phone_number)

    expect(page).to have_field('Set status of selected to')
    expect(page).to have_button('Update')
  end
end
