require 'rails_helper'

RSpec.feature 'Changing a users associated organisations' do
  let(:support_user) { create(:dfe_user) }
  let(:computacenter_support_user) { create(:computacenter_user) }
  let(:school_user) { create(:school_user) }
  let(:trust) { create(:trust) }
  let(:trust_school_1) { create(:school, responsible_body: trust, name: 'AAA school') }
  let(:trust_school_2) { create(:school, responsible_body: trust, name: 'BBB school') }
  let(:other_school) { create(:school, name: 'CCC school') }
  let(:responsible_body_user_with_multiple_schools) { create(:trust_user, responsible_body: trust, schools: [trust_school_1, trust_school_2]) }
  let(:other_trust) { create(:trust) }
  let(:other_local_authority) { create(:local_authority) }
  let(:search_page) { PageObjects::Support::Users::SearchPage.new }
  let(:results_page) { PageObjects::Support::Users::ResultsPage.new }
  let(:associated_organisations_page) { PageObjects::Support::Users::AssociatedOrganisationsPage.new }
  let(:matching_schools_page) { PageObjects::Support::Users::MatchingSchoolsPage.new }
  let(:matching_responsible_bodies_page) { PageObjects::Support::Users::MatchingResponsibleBodiesPage.new }

  scenario 'a support user sees a Change link next to the users assocations' do
    given_i_am_logged_in_as_a_support_user
    when_i_search_for_an_existing_user_by_email
    then_i_see_their_associated_organisations
    and_i_see_a_link_to_change_their_associated_organisations
  end

  scenario 'a Computacenter support user does not see a Change link next to the users assocations' do
    given_i_am_logged_in_as_a_computacenter_support_user
    when_i_search_for_an_existing_user_by_email
    then_i_see_their_associated_organisations
    and_i_do_not_see_a_link_to_change_their_associated_organisations
  end

  scenario 'clicking the Change link shows the  associated organisations' do
    given_i_am_logged_in_as_a_support_user
    when_i_search_for_an_existing_user_by_email
    and_i_click_the_link_to_change_their_associated_organisations
    then_i_see_their_associated_schools_and_responsible_body
    and_i_see_a_link_to_remove_each_school
    and_i_see_a_link_to_remove_the_responsible_body
  end

  scenario 'clicking a school Remove link removes the school' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_associated_organisations_page
    and_i_click_the_remove_link_next_to_a_school
    then_i_no_longer_see_the_removed_school_in_their_schools
    and_i_see_a_message_telling_me_the_school_has_been_removed
  end

  scenario 'clicking the responsible body Remove link removes the responsible_body' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_associated_organisations_page
    and_i_click_the_remove_link_next_to_the_responsible_body
    then_i_see_the_user_has_no_responsible_body
    and_i_see_a_message_telling_me_the_responsible_body_has_been_removed
  end

  scenario 'entering a partial school name lets me associate schools matching that name' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_associated_organisations_page
    and_i_enter_a_partial_school_name
    then_i_see_schools_matching_that_name
    and_i_see_an_associate_button_next_to_each_school
    when_i_click_the_associate_button
    then_i_see_the_school_added_to_their_schools
    and_i_see_a_message_telling_me_the_school_has_been_associated
  end

  scenario 'entering the URN of a school that is already associated shows it as already associated' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_associated_organisations_page
    and_i_enter_a_school_urn_that_the_user_already_has
    then_i_see_the_school_is_already_associated
    and_i_dont_see_a_button_to_associate_the_school
  end

  scenario 'entering a partial responsible body name lets me associate responsible bodies matching that name' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_associated_organisations_page
    and_i_enter_a_partial_responsible_body_name
    then_i_see_responsible_bodies_matching_that_name
    and_i_see_an_associate_button_next_to_each_responsible_body
    when_i_click_the_associate_button_next_to_the_responsible_body
    then_i_see_the_new_responsible_body_replaces_their_existing_responsible_body
    and_i_see_a_message_telling_me_the_responsible_body_has_been_associated
  end

  scenario 'entering the name of a responsible_body that is already associated shows it as already associated' do
    given_i_am_logged_in_as_a_support_user
    when_i_visit_a_users_associated_organisations_page
    and_i_enter_a_responsible_body_name_that_the_user_already_has
    then_i_see_the_responsible_body_is_already_associated
    and_i_dont_see_a_button_to_associate_the_responsible_body
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

  def then_i_see_their_associated_organisations
    expect(results_page).to be_displayed
    expect(results_page.users.first).to have_text(responsible_body_user_with_multiple_schools.email_address)
    expect(results_page.users.first).to have_text(trust_school_1.name)
    expect(results_page.users.first).to have_text(trust_school_2.name)
  end

  def and_i_see_a_link_to_change_their_associated_organisations
    expect(results_page.users.first).to have_link('Change')
  end

  def and_i_do_not_see_a_link_to_change_their_associated_organisations
    expect(results_page.users.first).not_to have_link('Change')
  end

  def and_i_click_the_link_to_change_their_associated_organisations
    within(results_page.users.first) do
      click_on 'Change'
    end
  end

  def then_i_see_their_associated_schools_and_responsible_body
    expect(associated_organisations_page).to be_displayed
    expect(associated_organisations_page.schools.size).to eq(2)
    expect(associated_organisations_page.schools[0]).to have_text(trust_school_1.name)
    expect(associated_organisations_page.schools[1]).to have_text(trust_school_2.name)
    expect(associated_organisations_page.responsible_body).to have_text(trust.name)
  end

  def and_i_see_a_link_to_remove_each_school
    expect(associated_organisations_page.schools[0]).to have_css('input[type=submit][value=Remove]')
    expect(associated_organisations_page.schools[1]).to have_css('input[type=submit][value=Remove]')
  end

  def and_i_see_a_link_to_remove_the_responsible_body
    expect(associated_organisations_page.responsible_body).to have_css('input[type=submit][value=Remove]')
  end

  def when_i_visit_a_users_associated_organisations_page
    visit(associated_organisations_support_user_path(responsible_body_user_with_multiple_schools))
  end

  def and_i_click_the_remove_link_next_to_a_school
    within(associated_organisations_page.schools[0]) do
      click_on('Remove')
    end
  end

  def then_i_no_longer_see_the_removed_school_in_their_schools
    expect(associated_organisations_page.schools.size).to eq(1)
    expect(associated_organisations_page.schools[0]).to have_text(trust_school_2.name)
  end

  def and_i_see_a_message_telling_me_the_school_has_been_removed
    expect(associated_organisations_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is no longer associated with #{trust_school_1.name}")
  end

  def then_i_see_the_user_has_no_responsible_body
    expect(associated_organisations_page).not_to have_responsible_body
  end

  def and_i_click_the_remove_link_next_to_the_responsible_body
    within(associated_organisations_page.responsible_body) do
      click_on('Remove')
    end
  end

  def and_i_see_a_message_telling_me_the_responsible_body_has_been_removed
    expect(associated_organisations_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is no longer associated with a Responsible body")
  end

  def and_i_enter_a_partial_school_name
    fill_in 'School name or URN', with: other_school.name.first(3)
    associated_organisations_page.submit_school_name_or_urn.click
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
    expect(associated_organisations_page.schools.size).to eq(3)
    expect(associated_organisations_page.schools[2]).to have_text(other_school.name)
  end

  def and_i_see_a_message_telling_me_the_school_has_been_associated
    expect(associated_organisations_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is now associated with #{other_school.name}")
  end

  def and_i_enter_a_school_urn_that_the_user_already_has
    fill_in 'School name or URN', with: trust_school_1.urn
    associated_organisations_page.submit_school_name_or_urn.click
  end

  def then_i_see_the_school_is_already_associated
    expect(matching_schools_page).to be_displayed
    expect(matching_schools_page.school_names).to all(have_text(trust_school_1.name))
    expect(matching_schools_page.schools[0]).to have_text('already associated')
  end

  def and_i_dont_see_a_button_to_associate_the_school
    expect(matching_schools_page.schools[0]).not_to have_button('Associate')
  end

  def and_i_enter_a_partial_responsible_body_name
    fill_in 'Responsible body name', with: other_local_authority.name.first(3)
    associated_organisations_page.submit_responsible_body_name.click
  end

  def then_i_see_responsible_bodies_matching_that_name
    expect(matching_responsible_bodies_page).to be_displayed
    expect(matching_responsible_bodies_page.responsible_body_names).to all(have_text(other_school.name.first(3)))
  end

  def and_i_see_an_associate_button_next_to_each_responsible_body
    expect(matching_responsible_bodies_page.responsible_bodies).to all(have_button('Associate'))
  end

  def when_i_click_the_associate_button_next_to_the_responsible_body
    matching_responsible_bodies_page.associate_responsible_body_link.click
  end

  def then_i_see_the_new_responsible_body_replaces_their_existing_responsible_body
    expect(associated_organisations_page.responsible_body).not_to have_text(trust.name)
    expect(associated_organisations_page.responsible_body).to have_text(other_local_authority.name)
  end

  def and_i_see_a_message_telling_me_the_responsible_body_has_been_associated
    expect(associated_organisations_page).to have_text("#{responsible_body_user_with_multiple_schools.full_name} is now associated with #{other_local_authority.name}")
  end

  def and_i_enter_a_responsible_body_name_that_the_user_already_has
    fill_in 'Responsible body name', with: trust.name
    associated_organisations_page.submit_responsible_body_name.click
  end

  def then_i_see_the_responsible_body_is_already_associated
    expect(matching_responsible_bodies_page).to be_displayed
    expect(matching_responsible_bodies_page.responsible_body_names).to all(have_text(trust.name))
    expect(matching_responsible_bodies_page.responsible_bodies[0]).to have_text('already associated')
  end

  def and_i_dont_see_a_button_to_associate_the_responsible_body
    expect(matching_responsible_bodies_page.responsible_bodies[0]).not_to have_button('Associate')
  end
end
