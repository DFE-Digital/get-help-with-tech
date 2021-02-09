require 'rails_helper'

RSpec.feature 'Managing GIAS updates to schools from the support area', type: :feature do
  let(:local_authority) { create(:local_authority, name: 'Coventry') }

  scenario 'Third-line support users can see the GIAS updates' do
    when_i_sign_in_as_a_third_line_support_user
    and_i_visit_the_support_page
    then_i_see_a_link_to_the_gias_updates
  end

  scenario 'Third-line support users can navigate to the schools to add list' do
    given_there_are_schools_to_add
    when_i_sign_in_as_a_third_line_support_user
    and_i_visit_the_support_page
    when_i_select_the_gias_updates_link
    and_i_select_the_schools_to_add_link
    then_i_see_the_list_of_schools_to_add
  end

  scenario 'Third-line support users can add a school' do
    given_there_are_schools_to_add
    when_i_sign_in_as_a_third_line_support_user
    when_i_visit_the_schools_to_add_page
    and_i_click_on_a_school_to_add
    then_i_can_see_details_of_the_school_to_add
    when_i_click_on_the_add_school_button
    then_i_see_the_updated_list_of_schools_to_add
  end

  scenario 'Third-line support users can navigate to the schools to close list' do
    given_there_are_schools_to_close
    when_i_sign_in_as_a_third_line_support_user
    and_i_visit_the_support_page
    when_i_select_the_gias_updates_link
    and_i_select_the_schools_to_close_link
    then_i_see_the_list_of_schools_to_close
  end

  scenario 'Third-line support users can close a school' do
    given_there_are_schools_to_close
    when_i_sign_in_as_a_third_line_support_user
    when_i_visit_the_schools_to_close_page
    and_i_click_on_a_school_to_close
    then_i_can_see_details_of_the_school_to_close
    when_i_click_on_the_close_school_button
    then_i_see_the_updated_list_of_schools_to_close
  end

  scenario 'Non-third-line support users cannot see the GIAS updates' do
    when_i_sign_in_as_a_support_user
    and_i_visit_the_support_page
    then_i_do_not_see_a_link_to_the_gias_updates
  end

  scenario 'Non-third-line support users cannot navigate to the schools to add list' do
    given_there_are_schools_to_add
    when_i_sign_in_as_a_support_user
    when_i_visit_the_schools_to_add_page
    then_i_see_a_forbidden_message
  end

  scenario 'Non-third-line support users cannot add a school' do
    given_there_are_schools_to_add
    when_i_sign_in_as_a_support_user
    when_i_visit_a_school_to_be_added_page
    then_i_see_a_forbidden_message
  end

  scenario 'Non-third-line support users cannot navigate to the schools to close list' do
    given_there_are_schools_to_close
    when_i_sign_in_as_a_support_user
    when_i_visit_the_schools_to_close_page
    then_i_see_a_forbidden_message
  end

  scenario 'Non-third-line support users cannot close a school' do
    given_there_are_schools_to_close
    when_i_sign_in_as_a_support_user
    when_i_visit_a_school_to_be_closed_page
    then_i_see_a_forbidden_message
  end

  def given_there_are_schools_to_add
    @schools_to_add = [
      create(:staged_school, :la_maintained, name: 'Big School', urn: 100_001, responsible_body_name: local_authority.name, status: 'open'),
      create(:staged_school, :la_maintained, name: 'High School', urn: 100_002, responsible_body_name: local_authority.name, status: 'open'),
    ]
  end

  def given_there_are_schools_to_close
    @schools_to_close = [
      create(:staged_school, :la_maintained, name: 'Low School', urn: 100_003, responsible_body_name: local_authority.name, status: 'closed'),
      create(:staged_school, :la_maintained, name: 'Small School', urn: 100_004, responsible_body_name: local_authority.name, status: 'closed'),
    ]

    @schools = @schools_to_close.map do |s|
      create(:school, name: s.name, urn: s.urn, responsible_body: local_authority, status: 'open')
    end
  end

  def when_i_sign_in_as_a_third_line_support_user
    sign_in_as create(:support_user, :third_line)
  end

  def when_i_sign_in_as_a_support_user
    sign_in_as create(:support_user)
  end

  def and_i_visit_the_support_page
    visit support_home_path
  end

  def when_i_select_the_gias_updates_link
    click_on 'GIAS updates'
  end

  def when_i_visit_the_schools_to_add_page
    visit support_gias_schools_to_add_index_path
  end

  def when_i_visit_a_school_to_be_added_page
    visit support_gias_schools_to_add_path(urn: @schools_to_add.first.urn)
  end

  def when_i_visit_the_schools_to_close_page
    visit support_gias_schools_to_close_index_path
  end

  def when_i_visit_a_school_to_be_closed_page
    visit support_gias_schools_to_close_path(urn: @schools_to_close.first.urn)
  end

  def and_i_click_on_a_school_to_add
    click_on @schools_to_add.first.urn.to_s
  end

  def and_i_click_on_a_school_to_close
    click_on @schools_to_close.first.urn.to_s
  end

  def then_i_can_see_details_of_the_school_to_add
    school = @schools_to_add.first
    expect(page).to have_text(school.responsible_body_name)
    expect(page).to have_text(school.name)
    expect(page).to have_text(school.human_for_school_type)
  end

  def then_i_can_see_details_of_the_school_to_close
    school = @schools_to_close.first
    expect(page).to have_text(school.responsible_body_name)
    expect(page).to have_text(school.name)
    expect(page).to have_text(school.human_for_school_type)
  end

  def when_i_click_on_the_add_school_button
    click_on 'Add school'
  end

  def when_i_click_on_the_close_school_button
    click_on 'Close school'
  end

  def then_i_see_the_updated_list_of_schools_to_close
    school = @schools_to_close.first
    expect(page).to have_text("#{school.name} (#{school.urn}) has been closed")

    within('#schools-to-close-table') do
      expect(page).not_to have_link(school.urn.to_s)
      expect(page).not_to have_text(school.name)

      school = @schools_to_close.last
      expect(page).to have_link(school.urn.to_s)
      expect(page).to have_text(school.name)
    end
  end

  def then_i_see_the_updated_list_of_schools_to_add
    school = @schools_to_add.first
    expect(page).to have_text("#{school.name} (#{school.urn}) added")

    within('#schools-to-add-table') do
      expect(page).not_to have_link(school.urn.to_s)
      expect(page).not_to have_text(school.name)

      school = @schools_to_add.last
      expect(page).to have_link(school.urn.to_s)
      expect(page).to have_text(school.name)
    end
  end

  def and_i_select_the_schools_to_add_link
    click_on 'Schools to be added (2)'
  end

  def and_i_select_the_schools_to_close_link
    click_on 'Schools to be closed (2)'
  end

  def then_i_see_the_list_of_schools_to_add
    @schools_to_add.each do |school|
      expect(page).to have_link(school.urn.to_s)
      expect(page).to have_text(school.name)
      expect(page).to have_text(school.responsible_body_name)
    end
  end

  def then_i_see_the_list_of_schools_to_close
    @schools_to_close.each do |school|
      expect(page).to have_link(school.urn.to_s)
      expect(page).to have_text(school.name)
      expect(page).to have_text(school.responsible_body_name)
    end
  end

  def then_i_see_a_link_to_the_gias_updates
    expect(page).to have_link('GIAS updates')
  end

  def then_i_do_not_see_a_link_to_the_gias_updates
    expect(page).not_to have_link('GIAS updates')
  end

  def then_i_see_a_forbidden_message
    expect(page).to have_text('Forbidden')
    expect(page).to have_text("You're not allowed to do that")
  end
end
