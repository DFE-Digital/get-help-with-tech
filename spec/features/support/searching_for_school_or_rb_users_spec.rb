require 'rails_helper'

RSpec.feature 'Searching for school or RB users' do
  let(:search_page) { PageObjects::Support::Users::SearchPage.new }
  let(:results_page) { PageObjects::Support::Users::ResultsPage.new }
  let(:school_page) { PageObjects::Support::SchoolDetailsPage.new }
  let(:support_user) { create(:support_user) }

  scenario 'finding a user by their name or email address' do
    given_i_am_signed_in_as_a_support_user
    and_there_are_school_and_responsible_body_users

    when_i_follow_the_links_to_find_users
    and_i_search_for_an_existing_school_user_by_their_name
    then_i_see_the_school_user_on_the_results_page

    when_i_search_again
    and_i_search_for_an_existing_school_user_by_their_email
    then_i_see_the_school_user_on_the_results_page
    and_i_can_navigate_to_the_support_page_for_their_school
  end

  def given_i_am_signed_in_as_a_support_user
    sign_in_as support_user
  end

  def and_there_are_school_and_responsible_body_users
    create(:school_user, full_name: 'Jane Smith', email_address: 'jsmith@school.sch.uk')
    create(:school_user, full_name: 'David Jones', email_address: 'djones@another-school.sch.uk')
    create(:local_authority_user, full_name: 'Debbie Barry', email_address: 'dbarry@council.gov.uk')
  end

  def when_i_follow_the_links_to_find_users
    click_link 'Find users'
  end

  def when_i_search_again
    results_page.another_search.click
  end

  def and_i_search_for_an_existing_school_user_by_their_name
    search_page.search_term.set 'Jane Smith'
    search_page.submit.click
  end

  def and_i_search_for_an_existing_school_user_by_their_email
    search_page.search_term.set 'jsmith@school.sch.uk'
    search_page.submit.click
  end

  def then_i_see_the_school_user_on_the_results_page
    expect(results_page).to be_displayed
    expect(results_page.users.size).to eq(1)
    expect(results_page.users.first).to have_text('jsmith@school.sch.uk')
    expect(results_page).not_to have_text('djones@another-school.sch.uk')
  end

  def and_i_can_navigate_to_the_support_page_for_their_school
    click_link User.find_by(full_name: 'Jane Smith').school.name
    expect(school_page).to be_displayed
  end
end
