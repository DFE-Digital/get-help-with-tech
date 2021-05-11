require 'rails_helper'

RSpec.describe 'Changing users’ associated organisations' do
  let(:support_user) { create(:dfe_user) }
  let(:computacenter_support_user) { create(:computacenter_user) }
  let(:school_user) { create(:school_user) }
  let(:trust) { create(:trust) }
  let(:trust_school_1) { create(:school, responsible_body: trust, name: 'AAA school') }
  let(:trust_school_2) { create(:school, responsible_body: trust, name: 'BBB school') }
  let(:other_school_1) { create(:school, name: 'CCC school', urn: 123_456, town: 'Westminster', postcode: 'AB12 3AA') }
  let(:other_school_2) { create(:school, name: 'DDD school') }
  let(:responsible_body_user_with_multiple_schools) { create(:trust_user, responsible_body: trust, schools: [trust_school_1, trust_school_2]) }
  let!(:other_local_authority) { create(:local_authority, name: 'AN ALL-UPPERCASE LA') }
  let(:results_page) { PageObjects::Support::Users::ResultsPage.new }
  let(:user_page) { PageObjects::Support::Users::UserPage.new }
  let(:user_schools_page) { PageObjects::Support::Users::SchoolsPage.new }
  let(:matching_schools_page) { PageObjects::Support::Users::MatchingSchoolsPage.new }

  it 'a Computacenter support user cannot change a user’s organisations' do
    given_i_am_logged_in_as_a_computacenter_support_user
    when_i_search_for_an_existing_user_by_email
    then_i_see_their_associated_organisations
    and_i_navigate_to_the_user_page
    and_i_do_not_see_a_link_to_change_their_associated_organisations
  end

  it 'a support agent removes a user from a school' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_schools_page
    and_i_remove_the_first_school
    then_i_no_longer_see_the_removed_school_in_their_schools
    and_i_see_a_message_telling_me_the_schools_have_been_updated
  end

  it 'a support agent removes a user from a responsible body' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_support_page
    and_i_start_changing_the_responsible_body
    and_i_remove_the_responsible_body
    then_i_see_the_user_has_no_responsible_body
    and_i_see_a_message_telling_me_the_responsible_body_has_been_removed
  end

  it 'a support agent adds a user to a school by partially matching on the school name (when there is a single match)' do
    given_i_am_logged_in_as_a_support_user
    and_there_are_schools_in_the_system
    when_i_visit_a_users_schools_page
    and_i_enter_a_partial_school_name_that_matches_only_one_school
    then_i_see_the_school_added_to_their_schools
    and_i_see_a_message_telling_me_the_school_has_been_associated
  end

  it 'a support agent adds a user to a school by partially matching on the school name (when there are multiple matches)' do
    given_i_am_logged_in_as_a_support_user
    and_there_are_schools_in_the_system
    when_i_visit_a_users_schools_page
    and_i_enter_a_partial_school_name_that_matches_multiple_schools
    then_i_see_schools_matching_that_name
    when_i_select_the_appropriate_school
    then_i_see_the_school_added_to_their_schools
    and_i_see_a_message_telling_me_the_school_has_been_associated
  end

  it 'a support user cannot add a user to a school twice' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_schools_page
    and_i_enter_a_school_urn_that_the_user_already_has
    then_i_see_the_school_is_already_associated
    and_i_am_not_able_to_associate_the_school
  end

  it 'a support agent moves the user to a different responsible body' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_support_page
    and_i_start_changing_the_responsible_body
    and_i_select_a_new_responsible_body_name
    then_i_see_the_new_responsible_body_replaces_their_existing_responsible_body
    and_i_see_a_message_telling_me_the_responsible_body_has_been_associated
  end

  def given_i_am_logged_in_as_a_support_user
    sign_in_as support_user
  end

  def given_i_am_logged_in_as_a_computacenter_support_user
    sign_in_as computacenter_support_user
  end

  def and_there_are_schools_in_the_system
    other_school_1
    other_school_2
  end

  def when_i_search_for_an_existing_user_by_email
    visit '/support'
    click_on 'Find users'
    fill_in 'Email address or name', with: responsible_body_user_with_multiple_schools.email_address
    click_on 'Search'
  end

  def and_i_navigate_to_the_user_page
    within results_page.users.first do
      find('h3 a').click
    end
  end

  def then_i_see_their_associated_organisations
    expect(results_page).to be_displayed
    expect(results_page.users.first).to have_text(responsible_body_user_with_multiple_schools.email_address)
    expect(results_page.users.first).to have_text(trust_school_1.name)
    expect(results_page.users.first).to have_text(trust_school_2.name)
  end

  def and_i_do_not_see_a_link_to_change_their_associated_organisations
    expect(results_page.users.first).not_to have_link('Change responsible body')
  end

  def when_i_visit_a_users_support_page
    visit support_user_path(responsible_body_user_with_multiple_schools)
  end

  def when_i_visit_a_users_schools_page
    visit support_user_schools_path(responsible_body_user_with_multiple_schools)
  end

  def and_i_remove_the_first_school
    uncheck trust_school_1.name
    click_on 'Update'
  end

  def then_i_no_longer_see_the_removed_school_in_their_schools
    expect(user_page.summary_list['Schools']).not_to have_text(trust_school_1.name)
    expect(user_page.summary_list['Schools']).to have_text(trust_school_2.name)
  end

  def and_i_see_a_message_telling_me_the_schools_have_been_updated
    expect(user_schools_page).to have_text('Schools updated')
  end

  def then_i_see_the_user_has_no_responsible_body
    expect(user_page.summary_list['Responsible body'].value).to be_blank
  end

  def and_i_start_changing_the_responsible_body
    click_on 'Change responsible body'
  end

  def and_i_remove_the_responsible_body
    choose 'Remove user from responsible body'
    click_on 'Update'
  end

  def and_i_see_a_message_telling_me_the_responsible_body_has_been_removed
    expect(user_schools_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is no longer associated with a responsible body")
  end

  def and_i_enter_a_partial_school_name_that_matches_only_one_school
    fill_in 'School name, URN or UKPRN', with: other_school_1.name.first(3).downcase
    user_schools_page.submit_school_name_or_urn.click
  end

  def and_i_enter_a_partial_school_name_that_matches_multiple_schools
    fill_in 'School name, URN or UKPRN', with: 'school'
    user_schools_page.submit_school_name_or_urn.click
  end

  def then_i_see_schools_matching_that_name
    expect(matching_schools_page).to be_displayed
    expect(matching_schools_page.form_with_suggested_schools).to have_text(other_school_1.name)
  end

  def when_i_select_the_appropriate_school
    choose 'CCC school (123456, Westminster, AB12 3AA)'
    click_on 'Grant access'
  end

  def then_i_see_the_school_added_to_their_schools
    expect(user_page.summary_list['Schools']).to have_text(other_school_1.name)
  end

  def and_i_see_a_message_telling_me_the_school_has_been_associated
    expect(user_schools_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is now associated with #{other_school_1.name}")
  end

  def and_i_enter_a_school_urn_that_the_user_already_has
    fill_in 'School name, URN or UKPRN', with: trust_school_1.urn
    user_schools_page.submit_school_name_or_urn.click
  end

  def then_i_see_the_school_is_already_associated
    expect(matching_schools_page).to be_displayed
    expect(matching_schools_page.existing_schools.text).to include(trust_school_1.name, trust_school_2.name)
  end

  def and_i_am_not_able_to_associate_the_school
    expect(matching_schools_page).not_to have_form_with_suggested_schools
  end

  def and_i_select_a_new_responsible_body_name
    choose 'Move user to a different responsible body'
    select other_local_authority.name, from: 'New responsible body'
    click_on 'Update'
  end

  def then_i_see_the_new_responsible_body_replaces_their_existing_responsible_body
    expect(user_page.summary_list['Responsible body']).not_to have_text(trust.name)
    expect(user_page.summary_list['Responsible body']).to have_text(other_local_authority.name)
  end

  def and_i_see_a_message_telling_me_the_responsible_body_has_been_associated
    expect(user_schools_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is now associated with #{other_local_authority.name}")
  end
end
