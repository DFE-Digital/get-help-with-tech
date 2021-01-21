require 'rails_helper'

RSpec.describe 'Adjusting allocations for many schools' do
  let(:support_user) { create(:support_user) }
  let(:schools) { create_list(:school, 3, :with_std_device_allocation, order_state: :cannot_order) }
  let(:bad_urn) { '12492903' }
  let(:valid_and_invalid_urns_and_allocations) do
    <<-DATA
      #{schools[0].urn}       123
      #{schools[1].urn} ,  , 234
      #{bad_urn}   22
    DATA
  end

  before do
    stub_computacenter_outgoing_api_calls
  end

  scenario 'setting allocations for many schools' do
    given_i_am_logged_in_as_a_support_user
    and_i_click 'Find and manage schools'
    and_i_click 'Adjust allocations for many organisations'
    then_i_see_a_form_to_enter_urns_and_allocations

    when_i_fill_in_the_form_with_2_valid_urns_and_allocations_separated_by_arbitrary_spaces_and_commas_plus_1_invalid_urn
    and_i_click 'Adjust allocations'
    then_i_see_a_message_telling_me_how_many_allocations_were_updated
    and_i_see_a_message_telling_me_how_many_allocations_failed
    and_i_see_an_error_message_row_for_each_failed_allocation
  end

  def given_i_am_logged_in_as_a_support_user
    sign_in_as support_user
  end

  def then_i_see_a_form_to_enter_urns_and_allocations
    expect(page).to have_css('h1', text: 'Adjust allocations for many schools')
    expect(page).to have_css('textarea#support-urns-and-allocations-form-urns-and-allocations-field')
  end

  def and_i_click(text)
    click_on text
  end

  def when_i_fill_in_the_form_with_2_valid_urns_and_allocations_separated_by_arbitrary_spaces_and_commas_plus_1_invalid_urn
    fill_in 'support-urns-and-allocations-form-urns-and-allocations-field', with: valid_and_invalid_urns_and_allocations
  end

  def then_i_see_a_message_telling_me_how_many_allocations_were_updated
    expect(page).to have_text '2 allocations updated'
  end

  def and_i_see_a_message_telling_me_how_many_allocations_failed
    expect(page).to have_text '1 failure'
  end

  def and_i_see_an_error_message_row_for_each_failed_allocation
    expect(page.find('#allocation-errors tbody').find_all('tr').size).to eq(1)
    expect(page.find('#allocation-errors tbody tr')).to have_text(bad_urn)
    expect(page.find('#allocation-errors tbody tr')).to have_text("Validation failed: 'School' must exist")
  end
end
