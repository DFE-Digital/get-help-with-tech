require 'rails_helper'

RSpec.feature 'Searching for schools by URNs' do
  let(:search_page) { PageObjects::Computacenter::School::SearchPage.new }
  let(:results_page) { PageObjects::Computacenter::School::ResultsPage.new }
  let(:computacenter_user) { create(:computacenter_user) }
  let(:schools) { create_list(:school, 2) }
  let(:bad_urn) { '12492903' }

  scenario 'happy journey' do
    given_i_am_signed_in_as_a_computacenter_user
    when_i_follow_the_link_to_find_schools
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

  def given_i_am_signed_in_as_a_computacenter_user
    sign_in_as computacenter_user
  end

  def when_i_follow_the_link_to_find_schools
    click_link 'Find schools'
  end

  def then_i_see_the_schools_search_page
    expect(search_page).to be_displayed
  end

  def when_i_fill_in_some_urns
    data = schools.map(&:urn).append(bad_urn).join("\r\n")
    search_page.urns.set data
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

  def when_i_click_on_perform_another_search
    results_page.another_search.click
  end
end
