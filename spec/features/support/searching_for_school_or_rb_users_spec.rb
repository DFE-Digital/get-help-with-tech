require 'rails_helper'

RSpec.describe 'Searching for school or RB users' do
  let(:search_page) { PageObjects::Support::Users::SearchPage.new }
  let(:results_page) { PageObjects::Support::Users::ResultsPage.new }
  let(:school_page) { PageObjects::Support::SchoolDetailsPage.new }
  let(:support_user) { create(:support_user) }
  let(:computacenter_user) { create(:computacenter_user, is_support: true) }

  it 'finding a user by their name or email address' do
    given_i_am_signed_in_as_a_support_user
    and_there_are_school_and_responsible_body_users

    when_i_follow_the_links_to_find_users
    and_i_search_for_an_existing_school_user_by_their_name
    then_i_see_the_school_user_on_the_results_page

    when_i_search_again
    and_i_search_for_an_existing_school_user_by_their_email
    then_i_see_the_school_user_on_the_results_page
    and_i_can_navigate_to_the_user_page
    and_i_can_navigate_to_the_support_page_for_their_school
  end

  it 'Computacenter user can only find users who have seen the privacy notice' do
    given_i_am_signed_in_as_a_computacenter_user
    and_there_are_school_and_responsible_body_users

    when_i_visit_support_and_follow_the_links_to_find_users
    and_i_search_for_a_school_user_who_has_not_seen_the_privacy_notice_by_their_name
    then_i_dont_see_the_school_user_on_the_results_page

    when_i_search_again
    and_i_search_for_a_school_user_who_has_seen_the_privacy_notice_by_their_name
    then_i_see_the_school_user_on_the_results_page
    and_i_can_navigate_to_the_user_page
    and_i_can_navigate_to_the_support_page_for_their_school
  end

  it 'users with no associated organisations are still shown in the results' do
    given_i_am_signed_in_as_a_support_user
    and_there_is_a_user_with_no_associations

    when_i_follow_the_links_to_find_users
    and_i_search_for_the_unassociated_user_by_email
    then_i_see_the_unassociated_user_on_the_results_page
  end

  def given_i_am_signed_in_as_a_support_user
    sign_in_as support_user
  end

  def given_i_am_signed_in_as_a_computacenter_user
    sign_in_as computacenter_user
  end

  def and_there_are_school_and_responsible_body_users
    create(:school_user, full_name: 'Jane Smith', email_address: 'jsmith@school.sch.uk', privacy_notice_seen_at: 1.month.ago)
    create(:school_user, full_name: 'David Jones', email_address: 'djones@another-school.sch.uk', privacy_notice_seen_at: nil)
    create(:local_authority_user, full_name: 'Debbie Barry', email_address: 'dbarry@council.gov.uk', privacy_notice_seen_at: 1.month.ago)
    create(:local_authority_user, full_name: 'Wendy Wilson', email_address: 'wendy.wilson@council.gov.uk', privacy_notice_seen_at: 1.month.ago)
  end

  def and_there_is_a_user_with_no_associations
    create(:user, full_name: 'Michelle Michaels', email_address: 'michelle.michaels@example.com', responsible_body_id: nil, schools: [], privacy_notice_seen_at: nil)
  end

  def when_i_follow_the_links_to_find_users
    click_link 'Find users'
  end

  def when_i_visit_support_and_follow_the_links_to_find_users
    visit '/support'
    click_link 'Find users'
  end

  def when_i_search_again
    results_page.another_search.click
  end

  def and_i_search_for_an_existing_school_user_by_their_name
    search_page.search_term.set 'Jane Smith'
    search_page.submit.click
  end

  def and_i_search_for_a_school_user_who_has_seen_the_privacy_notice_by_their_name
    search_page.search_term.set 'Jane Smith'
    search_page.submit.click
  end

  def and_i_search_for_a_school_user_who_has_not_seen_the_privacy_notice_by_their_name
    search_page.search_term.set 'David Jones'
    search_page.submit.click
  end

  def and_i_search_for_an_existing_school_user_by_their_email
    search_page.search_term.set 'jsmith@school.sch.uk'
    search_page.submit.click
  end

  def and_i_search_for_the_unassociated_user_by_email
    search_page.search_term.set 'michelle.michaels'
    search_page.submit.click
  end

  def then_i_see_the_school_user_on_the_results_page
    expect(results_page).to be_displayed
    expect(results_page.users.size).to eq(1)
    expect(results_page.users.first).to have_text('jsmith@school.sch.uk')
    expect(results_page).not_to have_text('djones@another-school.sch.uk')
  end

  def then_i_dont_see_the_school_user_on_the_results_page
    expect(results_page).to be_displayed
    expect(results_page.users.size).to eq(0)
    expect(results_page).not_to have_text('djones@another-school.sch.uk')
  end

  def then_i_see_the_unassociated_user_on_the_results_page
    expect(results_page).to be_displayed
    expect(results_page.users.size).to eq(1)
    expect(results_page.users.first).to have_text('michelle.michaels@example.com')
  end

  def and_i_can_navigate_to_the_user_page
    click_link 'Jane Smith'
    expect(page).to have_title('Jane Smith – Support')
  end

  def and_i_can_navigate_to_the_support_page_for_their_school
    click_link User.find_by(full_name: 'Jane Smith').school.name
    expect(school_page).to be_displayed
  end
end
