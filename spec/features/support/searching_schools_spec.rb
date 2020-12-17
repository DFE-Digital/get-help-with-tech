require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'Searching for schools by URNs' do
  let(:search_page) { PageObjects::Support::School::SearchPage.new }
  let(:results_page) { PageObjects::Support::School::ResultsPage.new }
  let(:support_user) { create(:support_user) }
  let(:schools) { create_list(:school, 2) }
  let(:responsible_body) { create(:trust) }
  let(:bad_urn) { '12492903' }
  let(:schools_who_can_order) { create_list(:school, 2, responsible_body: responsible_body, order_state: 'can_order') }

  scenario 'happy journey' do
    given_i_am_signed_in_as_a_support_user
    when_i_follow_the_links_to_find_schools
    then_i_see_the_schools_search_page

    when_i_fill_in_some_urns
    and_i_submit
    then_i_see_the_results_page
    and_i_see_summary_count_string
    and_i_see_one_error
    and_i_see_results_with_schools(2)

    when_i_click_on_perform_another_search
    then_i_see_the_schools_search_page
  end

  scenario 'searching by other criteria' do
    given_i_am_signed_in_as_a_support_user
    and_multiple_schools_from_the_same_responsible_body_in_different_order_states
    when_i_follow_the_links_to_find_schools
    then_i_see_the_schools_search_page

    when_i_choose_an_order_state_and_responsible_body
    and_i_submit
    then_i_see_the_results_page
    and_i_see_summary_count_string
    and_i_see_schools_matching_the_given_order_state_and_responsible_body

    when_i_click_on_perform_another_search
    then_i_see_the_schools_search_page
  end

  scenario 'exporting allocations as csv' do
    given_i_am_signed_in_as_a_support_user
    and_multiple_schools_from_the_same_responsible_body_in_different_order_states
    when_i_follow_the_links_to_find_schools
    then_i_see_the_schools_search_page

    when_i_choose_an_order_state_and_responsible_body
    and_i_submit
    then_i_see_the_results_page
    and_i_see_a_button_to_download_as_csv

    when_i_click_on_the_download_button
    then_i_download_a_csv
    and_the_csv_contains_data_for_the_correct_schools
  end

  def given_i_am_signed_in_as_a_support_user
    sign_in_as support_user
  end

  def and_multiple_schools_from_the_same_responsible_body_in_different_order_states
    schools_who_can_order
    create_list(:school, 2, responsible_body: responsible_body, order_state: 'cannot_order')
  end

  def when_i_follow_the_links_to_find_schools
    click_link 'Find and manage schools'
    click_link 'Find schools'
  end

  def then_i_see_the_schools_search_page
    expect(search_page).to be_displayed
  end

  def when_i_fill_in_some_urns
    data = schools.map(&:urn).append(bad_urn).join("\r\n")
    search_page.urns.set data
  end

  def when_i_choose_an_order_state_and_responsible_body
    select responsible_body.name, from: 'Responsible body'
    select 'They can order their full allocation because a closure or group of self-isolating children has been reported', from: 'Order state'
  end

  def and_i_see_schools_matching_the_given_order_state_and_responsible_body
    expect(results_page.results_table.responsible_bodies).to all(have_text(responsible_body.name))
    expect(results_page.results_table.order_states).to all(have_text('can_order'))
  end

  def and_i_submit
    search_page.submit.click
  end

  def then_i_see_the_results_page
    expect(results_page).to be_displayed
  end

  def and_i_see_summary_count_string
    expect(page).to have_content('2 schools found')
  end

  def and_i_see_one_error
    expect(page).to have_content('No schools found for 1 URN:')
  end

  def and_i_see_results_with_schools(count)
    expect(results_page.has_results_table?).to be_truthy
    expect(results_page.results_table.schools.size).to eql(count)
  end

  def and_i_see_a_button_to_download_as_csv
    expect(results_page).to have_button('Download allocations as CSV')
  end

  def when_i_click_on_the_download_button
    click_on('Download allocations as CSV')
  end

  def then_i_download_a_csv
    expect_download(content_type: 'text/csv')
    expect(page.body).to include(AllocationsExporter.headings.join(','))
  end

  def and_the_csv_contains_data_for_the_correct_schools
    rows = page.body.split("\n")
    expect(rows.size).to eq(3)
    expect(rows.map { |row| row.split(',').first }).to include('School URN', schools_who_can_order.first.urn.to_s, schools_who_can_order.last.urn.to_s)
  end

  def when_i_click_on_perform_another_search
    results_page.another_search.click
  end
end
