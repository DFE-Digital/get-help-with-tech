require 'rails_helper'

RSpec.feature 'Navigate school welcome wizard' do
  scenario 'view the welcome page' do
    as_a_new_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school
  end

  scenario 'view the privacy page' do
    as_a_new_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school

    when_i_click_continue
    then_i_see_a_privacy_notice
  end

  scenario 'the wizard resumes where left off' do
    as_a_new_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school

    when_i_click_continue
    then_i_see_a_privacy_notice

    when_i_sign_out
    and_then_sign_in_again
    then_i_see_a_privacy_notice
  end

  def as_a_new_school_user
    @user = create(:school_user, :new_visitor)
  end

  def when_i_sign_in_for_the_first_time
    visit validate_token_url_for(@user)
  end

  def then_i_see_a_welcome_page_for_my_school
    expect(page).to have_current_path(school_welcome_wizard_welcome_path)
    expect(page).to have_text("You’re signed in as #{@user.school.name}")
  end

  def when_i_click_continue
    click_on 'Continue'
  end

  def then_i_see_a_privacy_notice
    expect(page).to have_current_path(school_welcome_wizard_privacy_path)
    expect(page).to have_text('Privacy notice')
  end

  def when_i_sign_out
    sign_out
  end

  def and_then_sign_in_again
    visit validate_token_url_for(@user)
  end
end
