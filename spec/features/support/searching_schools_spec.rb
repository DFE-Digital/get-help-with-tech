require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'Searching for schools by URNs and other criteria' do
  let(:search_page) { PageObjects::Support::School::SearchPage.new }
  let(:results_page) { PageObjects::Support::School::ResultsPage.new }
  let(:support_user) { create(:support_user) }
  let(:schools) { create_list(:school, 2) }
  let(:responsible_body) { create(:trust) }
  let(:bad_urn) { '12492903' }
  let(:schools_who_can_order) { create_list(:school, 2, responsible_body:, order_state: 'can_order') }

  scenario 'support agent searches for a single school by name' do
    given_i_am_signed_in_as_a_support_user
    when_i_follow_the_links_to_find_schools
    then_i_see_the_schools_search_page

    when_i_fill_in_a_partial_name
    and_i_submit
    then_i_see_the_results_page
    and_i_see_results_with_schools(1)
    and_the_results_page_contains_one_school(schools.first)
  end

  scenario 'support agent searches by multiple URNs' do
    given_i_am_signed_in_as_a_support_user
    when_i_follow_the_links_to_find_schools
    then_i_see_the_schools_search_page

    when_i_fill_in_some_urns
    and_i_submit
    then_i_see_the_results_page
    and_i_see_summary_count_string
    and_i_see_one_error
    and_i_see_results_with_schools(2)

    and_i_see_a_button_to_download_as_csv
    when_i_click_on_the_download_button
    and_the_csv_contains_data_for_the_searched_schools
  end

  scenario 'support agent searches by order state and responsible body' do
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

  scenario 'support agent exports allocations as CSV' do
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

  context 'export of users scoped to schools' do
    let(:school_user1) { create(:school_user, email_address: 'user@can-order-school.sch.uk', school: schools_who_can_order.first) }
    let(:school_user2) { create(:school_user, email_address: 'user@another-can-order-school.sch.uk', school: schools_who_can_order.last) }
    let(:trust_user) { create(:trust_user, email_address: 'user@trust.gov.uk', responsible_body:) }
    let(:out_of_scope_school_user) { create(:school_user) }

    before do
      out_of_scope_school_user
    end

    scenario 'support agent exports users as CSV' do
      given_i_am_signed_in_as_a_support_user
      and_multiple_schools_from_the_same_responsible_body_in_different_order_states
      and_there_are_school_and_responsible_body_users
      when_i_follow_the_links_to_find_schools
      then_i_see_the_schools_search_page

      when_i_choose_an_order_state_and_responsible_body
      and_i_submit
      then_i_see_the_results_page
      and_i_see_a_button_to_download_users_as_csv

      when_i_click_on_the_download_users_button
      then_i_download_a_csv_of_users
      and_the_csv_contains_data_for_the_correct_users
    end
  end

  def given_i_am_signed_in_as_a_support_user
    sign_in_as support_user
  end

  def and_multiple_schools_from_the_same_responsible_body_in_different_order_states
    schools_who_can_order
    create_list(:school, 2, responsible_body:, order_state: 'cannot_order')
  end

  def and_there_are_school_and_responsible_body_users
    school_user1
    school_user2
    trust_user
  end

  def when_i_follow_the_links_to_find_schools
    click_link 'Find and manage schools'
    click_link 'Find organisations'
  end

  def then_i_see_the_schools_search_page
    expect(search_page).to be_displayed
  end

  def when_i_fill_in_a_partial_name
    search_page.search_by_name_urn_or_ukprn.choose
    search_page.name_or_identifier.set schools.first.urn
  end

  def when_i_fill_in_some_urns
    search_page.search_by_multiple_urn_or_ukprns.choose
    data = schools.map(&:urn).append(bad_urn).join("\r\n")
    search_page.identifiers.set data
  end

  def when_i_choose_an_order_state_and_responsible_body
    search_page.search_by_rb_or_order_state.choose
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
    expect(page).to have_content('2 organisations found')
  end

  def and_i_see_one_error
    expect(page).to have_content('No organisations found for 1 identifier:')
  end

  def and_i_see_results_with_schools(count)
    expect(results_page.has_results_table?).to be_truthy
    expect(results_page.results_table.schools.size).to eql(count)
  end

  def and_the_results_page_contains_one_school(school)
    expect(results_page.has_results_table?).to be_truthy
    expect(results_page.results_table.schools.first).to have_link(school.name, href: support_school_path(urn: school.urn))
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

  def and_i_see_a_button_to_download_users_as_csv
    expect(results_page).to have_button('Download users as CSV')
  end

  def when_i_click_on_the_download_users_button
    click_on('Download users as CSV')
  end

  def then_i_download_a_csv_of_users
    expect_download(content_type: 'text/csv')
    expect(page.body).to include(Support::UserReport.headers.join(','))
  end

  def and_the_csv_contains_data_for_the_searched_schools
    rows = page.body.split("\n")
    expect(rows.size).to eq(3)
    expect(rows.map { |row| row.split(',').first }).to include('School URN', schools.first.urn.to_s, schools.last.urn.to_s)
  end

  def and_the_csv_contains_data_for_the_correct_schools
    rows = page.body.split("\n")
    expect(rows.size).to eq(3)
    expect(rows.map { |row| row.split(',').first }).to include('School URN', schools_who_can_order.first.urn.to_s, schools_who_can_order.last.urn.to_s)
  end

  def and_the_csv_contains_data_for_the_correct_users
    rows = page.body.split("\n")
    expect(rows.size).to eq(4)
    expect(page.body).to have_content('email_address')
    expect(page.body).to have_content(school_user1.email_address)
    expect(page.body).to have_content(school_user2.email_address)
    expect(page.body).to have_content(trust_user.email_address)
    expect(page.body).not_to have_content(out_of_scope_school_user.email_address)
  end

  def when_i_click_on_perform_another_search
    results_page.another_search.click
  end
end
