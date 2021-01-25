require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'Find MNO Requests by telephone number', type: :feature do
  let(:local_authority_user) { create(:local_authority_user) }
  let(:mno_user) { create(:mno_user) }
  let(:other_mno) { create(:mobile_network, brand: 'Other MNO') }
  let(:user_from_other_mno) { create(:mno_user, name: 'Other MNO-User', organisation: 'Other MNO', mobile_network: other_mno) }
  let!(:extra_mobile_data_requests_for_mno) { create_list(:extra_mobile_data_request, 3, mobile_network: mno_user.mobile_network, created_by_user: local_authority_user) }
  let!(:extra_mobile_data_request_for_other_mno) { create(:extra_mobile_data_request, account_holder_name: 'other mno extra_mobile_data_request', mobile_network: other_mno, created_by_user: local_authority_user) }

  scenario 'visiting Your requests' do
    given_i_am_signed_in_as_an_mno_user
    and_i_click_on_the_your_requests_link
    then_i_see_my_list_of_requests
    and_i_see_a_form_to_find_requests_by_telephone_number
  end

  scenario 'finding requests by telephone number' do
    given_i_am_signed_in_as_an_mno_user
    and_i_click_on_the_your_requests_link
    when_I_enter_the_phone_numbers_of_the_requests_I_want_to_find
    and_i_click_the_find_requests_button
    then_i_see_a_list_of_requests_matching_those_phone_numbers
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

  def when_I_enter_the_phone_numbers_of_the_requests_I_want_to_find
    phones = [extra_mobile_data_requests_for_mno.first.device_phone_number,
              extra_mobile_data_requests_for_mno.second.device_phone_number].join("\r\n")

    fill_in 'Telephone numbers', with: phones
  end

  def and_i_click_the_find_requests_button
    click_on 'Find requests'
  end

  def then_i_see_a_list_of_requests_matching_those_phone_numbers
    expect(page).to have_content('2 requests found')
    (0..1).each do |n|
      request = extra_mobile_data_requests_for_mno[n]
      expect(page).to have_content(request.account_holder_name)
      expect(page).to have_content(request.device_phone_number)
    end
    request = extra_mobile_data_requests_for_mno.last
    expect(page).not_to have_content(request.account_holder_name)
    expect(page).not_to have_content(request.device_phone_number)
  end

  # context 'signed in as an mno user' do
  #   before do
  #     sign_in_as mno_user
  #   end
  #
  #   describe 'visiting Your requests' do
  #     before do
  #       click_on 'Your requests'
  #     end
  #
  #     scenario 'shows only requests from my MNO' do
  #       expect(page).to have_content('Requests for extra mobile data')
  #       expect(page).to have_content(mno_user.mobile_network.brand)
  #       expect(page).to have_content(extra_mobile_data_request_for_mno.account_holder_name)
  #       expect(page).not_to have_content(extra_mobile_data_request_for_other_mno.account_holder_name)
  #     end
  #
  #     scenario 'clicking Select All selects all checkboxes' do
  #       click_on 'all'
  #
  #       all('input[name="mno_extra_mobile_data_requests_form[extra_mobile_data_request_ids][]"]').each do |e|
  #         expect(e.checked?).to eq(true)
  #       end
  #     end
  #
  #     scenario 'clicking Select None de-selects all checkboxes' do
  #       check('mno_extra_mobile_data_requests_form[extra_mobile_data_request_ids][]')
  #       click_on 'none'
  #
  #       all('input[name="mno_extra_mobile_data_requests_form[extra_mobile_data_request_ids][]"]').each do |e|
  #         expect(e.checked?).to eq(false)
  #       end
  #     end
  #   end
  #
  #   context 'with several extra_mobile_data_requests shown' do
  #     # NOTE: a function, not a let, so that it re-runs each time
  #     def rendered_ids
  #       all('tbody tr').map { |e| e[:id].split('-').last.to_i }
  #     end
  #     let(:mno_extra_mobile_data_requests) do
  #       ExtraMobileDataRequest.where(mobile_network: mno_user.mobile_network)
  #     end
  #
  #     before do
  #       create_list(:extra_mobile_data_request, 5, status: 'new', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user)
  #       click_on 'Your requests'
  #     end
  #
  #     scenario 'clicking on a header sorts by that column' do
  #       click_on 'Account holder'
  #       expect(rendered_ids).to eq(mno_extra_mobile_data_requests.order(:account_holder_name).pluck(:id))
  #
  #       click_on 'Requested'
  #       expect(rendered_ids).to eq(mno_extra_mobile_data_requests.order(:created_at).pluck(:id))
  #     end
  #
  #     scenario 'clicking on a header twice sorts by that column in reverse order' do
  #       click_on 'Account holder'
  #       expect(rendered_ids).to eq(mno_extra_mobile_data_requests.order(:account_holder_name).pluck(:id))
  #
  #       click_on 'Account holder'
  #       expect(rendered_ids).to eq(mno_extra_mobile_data_requests.order(account_holder_name: :desc).pluck(:id))
  #     end
  #
  #     scenario 'updating selected extra_mobile_data_requests to a status applies that status' do
  #       all('input[name="mno_extra_mobile_data_requests_form[extra_mobile_data_request_ids][]"]').first(3).each(&:check)
  #       select('In progress', from: 'Set status of selected to')
  #       click_on('Update')
  #       expect(all('.extra_mobile_data_request-status').first(3)).to all(have_content('In progress'))
  #       expect(all('.extra_mobile_data_request-status').last(2)).to all(have_no_content('In progress'))
  #     end
  #
  #     scenario 'clicking Download as CSV downloads a CSV file' do
  #       click_on 'Download requests as CSV'
  #       expect_download(content_type: 'text/csv')
  #     end
  #   end
  #
  #   context 'with multiple pages of extra_mobile_data_requests' do
  #     original_pagination_value = Pagy::VARS[:items]
  #
  #     before do
  #       Pagy::VARS[:items] = 20
  #       create_list(:extra_mobile_data_request, 25, status: 'new', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user)
  #       click_on 'Your requests'
  #     end
  #
  #     after do
  #       Pagy::VARS[:items] = original_pagination_value
  #     end
  #
  #     it 'shows pagination' do
  #       expect(page).to have_link('Next')
  #     end
  #
  #     it 'shows all/none checkbox when on subsequent pages' do
  #       click_on('Next')
  #       expect { page.find('input#all-rows') }.not_to raise_error
  #     end
  #   end
  #
  #   context 'when the requests are complete or cancelled' do
  #     let!(:complete_request) do
  #       create(:extra_mobile_data_request, mobile_network: mno_user.mobile_network, created_by_user: local_authority_user, status: 'complete')
  #     end
  #     let!(:cancelled_request) do
  #       create(:extra_mobile_data_request, mobile_network: mno_user.mobile_network, created_by_user: local_authority_user, status: 'cancelled')
  #     end
  #
  #     before do
  #       extra_mobile_data_request_for_mno.update!(status: 'complete')
  #       click_on 'Your requests'
  #     end
  #
  #     it 'shows the status' do
  #       within("#request-#{complete_request.id}") do
  #         expect(page).to have_text('Complete')
  #       end
  #       within("#request-#{cancelled_request.id}") do
  #         expect(page).to have_text('Cancelled')
  #       end
  #     end
  #
  #     it 'does not show a link to Report a problem' do
  #       expect(page).not_to have_link('Report a problem')
  #     end
  #   end
  # end
end
