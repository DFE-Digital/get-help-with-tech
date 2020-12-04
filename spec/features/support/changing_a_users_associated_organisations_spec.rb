require 'rails_helper'

RSpec.feature 'Changing users’ associated organisations' do
  let(:support_user) { create(:dfe_user) }
  let(:computacenter_support_user) { create(:computacenter_user) }
  let(:school_user) { create(:school_user) }
  let(:trust) { create(:trust) }
  let(:trust_school_1) { create(:school, responsible_body: trust, name: 'AAA school') }
  let(:trust_school_2) { create(:school, responsible_body: trust, name: 'BBB school') }
  let(:other_school) { create(:school, name: 'CCC school') }
  let(:responsible_body_user_with_multiple_schools) { create(:trust_user, responsible_body: trust, schools: [trust_school_1, trust_school_2]) }
  let!(:other_local_authority) { create(:local_authority, name: 'AN ALL-UPPERCASE LA') }
  let(:results_page) { PageObjects::Support::Users::ResultsPage.new }
  let(:user_page) { PageObjects::Support::Users::UserPage.new }
  let(:user_schools_page) { PageObjects::Support::Users::SchoolsPage.new }
  let(:matching_schools_page) { PageObjects::Support::Users::MatchingSchoolsPage.new }

  scenario 'a Computacenter support user cannot change a user’s organisations' do
    given_i_am_logged_in_as_a_computacenter_support_user
    when_i_search_for_an_existing_user_by_email
    then_i_see_their_associated_organisations
    and_i_navigate_to_the_user_page
    and_i_do_not_see_a_link_to_change_their_associated_organisations
  end

  scenario 'a support agent removes a user from a school' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_schools_page
    and_i_click_the_remove_link_next_to_a_school
    then_i_no_longer_see_the_removed_school_in_their_schools
    and_i_see_a_message_telling_me_the_school_has_been_removed
  end

  scenario 'a support agent removes a user from a responsible body' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_support_page
    and_i_start_changing_the_responsible_body
    and_i_remove_the_responsible_body
    then_i_see_the_user_has_no_responsible_body
    and_i_see_a_message_telling_me_the_responsible_body_has_been_removed
  end

  scenario 'a support agent adds a user to a school by partially matching on the school name' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_schools_page
    and_i_enter_a_partial_school_name_in_any_case
    then_i_see_schools_matching_that_name
    and_i_see_an_associate_button_next_to_each_school
    when_i_click_the_associate_button
    then_i_see_the_school_added_to_their_schools
    and_i_see_a_message_telling_me_the_school_has_been_associated
  end

  scenario 'a support agent adds a user to a school by selecting it from an autocomplete' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_schools_page
    and_i_pick_a_school_via_the_schools_autocomplete
    then_i_see_one_school_matching_that_urn
  end

  scenario 'a support user cannot add a user to a school twice' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_schools_page
    and_i_enter_a_school_urn_that_the_user_already_has
    then_i_see_the_school_is_already_associated
    and_i_dont_see_a_button_to_associate_the_school
  end

  scenario 'a support agent moves the user to a different responsible body' do
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

  def when_i_search_for_an_existing_user_by_email
    visit '/support'
    click_on 'Find users'
    fill_in 'Enter an email address or name', with: responsible_body_user_with_multiple_schools.email_address
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

  def and_i_click_the_remove_link_next_to_a_school
    within(user_schools_page.schools[0]) do
      click_on('Remove')
    end
  end

  def then_i_no_longer_see_the_removed_school_in_their_schools
    expect(user_schools_page.schools.size).to eq(1)
    expect(user_schools_page.schools[0]).to have_text(trust_school_2.name)
  end

  def and_i_see_a_message_telling_me_the_school_has_been_removed
    expect(user_schools_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is no longer associated with #{trust_school_1.name}")
  end

  def then_i_see_the_user_has_no_responsible_body
    expect(user_page.summary_list['Responsible body'].value).to be_blank
  end

  def and_i_start_changing_the_responsible_body
    click_on 'Change responsible body'
  end

  def and_i_remove_the_responsible_body
    click_on 'Remove'
  end

  def and_i_see_a_message_telling_me_the_responsible_body_has_been_removed
    expect(user_schools_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is no longer associated with a responsible body")
  end

  def and_i_enter_a_partial_school_name_in_any_case
    fill_in 'School name or URN', with: other_school.name.first(3).downcase
    user_schools_page.submit_school_name_or_urn.click
  end

  def and_i_pick_a_school_via_the_schools_autocomplete
    # we don't want to do the full JS round-trip here so we'll simulate what the JS autocomplete
    # does, which is setting the hidden 'school-urn' attribute
    user_schools_page.school_urn(visible: false).set trust_school_1.urn
    user_schools_page.submit_school_name_or_urn.click
  end

  def then_i_see_one_school_matching_that_urn
    expect(matching_schools_page).to be_displayed
    expect(matching_schools_page.school_names.first).to have_text(trust_school_1.name)
  end

  def then_i_see_schools_matching_that_name
    expect(matching_schools_page).to be_displayed
    expect(matching_schools_page.school_names).to all(have_text(other_school.name.first(3)))
  end

  def and_i_see_an_associate_button_next_to_each_school
    expect(matching_schools_page.schools).to all(have_button('Associate'))
  end

  def when_i_click_the_associate_button
    matching_schools_page.associate_school_link.click
  end

  def then_i_see_the_school_added_to_their_schools
    expect(user_schools_page.schools.size).to eq(3)
    expect(user_schools_page.schools[2]).to have_text(other_school.name)
  end

  def and_i_see_a_message_telling_me_the_school_has_been_associated
    expect(user_schools_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is now associated with #{other_school.name}")
  end

  def and_i_enter_a_school_urn_that_the_user_already_has
    fill_in 'School name or URN', with: trust_school_1.urn
    user_schools_page.submit_school_name_or_urn.click
  end

  def then_i_see_the_school_is_already_associated
    expect(matching_schools_page).to be_displayed
    expect(matching_schools_page.school_names).to all(have_text(trust_school_1.name))
    expect(matching_schools_page.schools[0]).to have_text('already associated')
  end

  def and_i_dont_see_a_button_to_associate_the_school
    expect(matching_schools_page.schools[0]).not_to have_button('Associate')
  end

  def and_i_select_a_new_responsible_body_name
    select other_local_authority.name, from: 'support-user-responsible-body-form-responsible-body-field'
    click_on 'Move'
  end

  def then_i_see_the_new_responsible_body_replaces_their_existing_responsible_body
    expect(user_page.summary_list['Responsible body']).not_to have_text(trust.name)
    expect(user_page.summary_list['Responsible body']).to have_text(other_local_authority.name)
  end

  def and_i_see_a_message_telling_me_the_responsible_body_has_been_associated
    expect(user_schools_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is now associated with #{other_local_authority.name}")
  end
end
