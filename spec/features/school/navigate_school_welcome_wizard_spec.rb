require 'rails_helper'

RSpec.feature 'Navigate school welcome wizard' do
  let(:school) { create(:school, :with_std_device_allocation) }

  scenario 'step through the wizard as the first user for a school' do
    as_a_new_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school

    when_i_click_continue
    then_i_see_a_privacy_notice

    when_i_click_continue
    then_i_see_the_allocation_for_my_school

    when_i_click_continue
    then_i_see_the_order_your_own_page

    when_i_click_continue
    then_i_see_the_will_you_order_page
    when_i_choose_yes_and_click_continue
    then_i_see_the_school_home_page
  end

  scenario 'step through wizard as subsequent user' do
    as_a_subsequent_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school

    when_i_click_continue
    then_i_see_a_privacy_notice

    when_i_click_continue
    then_i_see_the_allocation_for_my_school

    when_i_click_continue
    then_i_see_the_order_your_own_page

    when_i_click_continue
    then_i_see_the_school_home_page
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
    @user = create(:school_user, :new_visitor, school: school)
  end

  def as_a_subsequent_school_user
    @user = create_list(:school_user, 2, :new_visitor, school: school).last
  end

  def when_i_sign_in_for_the_first_time
    visit validate_token_url_for(@user)
    click_on 'Continue'
  end

  def then_i_see_a_welcome_page_for_my_school
    expect(page).to have_current_path(school_welcome_wizard_welcome_path)
    expect(page).to have_text("You’re signed in as #{school.name}")
  end

  def when_i_click_continue
    click_on 'Continue'
  end

  def then_i_see_a_privacy_notice
    expect(page).to have_current_path(school_welcome_wizard_privacy_path)
    expect(page).to have_text('Privacy notice')
  end

  def then_i_see_the_allocation_for_my_school
    expect(page).to have_current_path(school_welcome_wizard_allocation_path)
    heading = I18n.t('page_titles.school_user_welcome_wizard.allocation.title', allocation: device_allocation)
    expect(page).to have_text(heading)
  end

  def then_i_see_the_order_your_own_page
    expect(page).to have_current_path(school_welcome_wizard_order_your_own_path)
    expect(page).to have_text('You can only order your full allocation if local restrictions are confirmed')
  end

  def then_i_see_the_school_home_page
    expect(page).to have_current_path(school_home_path)
    expect(page).to have_text(school.name)
    expect(page).to have_text('Get devices for your school')
  end

  def then_i_see_the_will_you_order_page
    expect(page).to have_current_path(school_welcome_wizard_will_you_order_path)
    expect(page).to have_text('Will you be one of the people placing orders for your school?')
  end

  def when_i_choose_yes_and_click_continue
    choose 'Yes, I will order devices'
    click_on 'Continue'
  end

  def when_i_sign_out
    sign_out
  end

  def and_then_sign_in_again
    visit validate_token_url_for(@user)
    click_on 'Continue'
  end

  def device_allocation
    school.std_device_allocation&.allocation || 0
  end
end
