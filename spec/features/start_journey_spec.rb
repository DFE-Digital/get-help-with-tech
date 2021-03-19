require 'rails_helper'

RSpec.feature 'View pages', type: :feature do
  scenario 'Root URL should be the home page' do
    when_i_visit_the_home_page
    then_i_should_see_the_service_name
  end

  scenario 'user would like to find out about free training and free support' do
    when_i_visit_the_home_page
    and_i_click_on_free_training_and_free_support_link
    then_i_should_see_the_edtech_programme_page
    and_the_page_title_should_be_set(@edtech_landing_page, 'Get free training and support to set up and use technology effectively')
  end

  scenario 'user would like to find out hot to get a digital platform setup' do
    when_i_visit_the_home_page
    and_i_click_on_get_funding_to_setup_platforms_link
    then_i_should_see_the_digital_platforms_page
    and_the_page_title_should_be_set(@digital_platforms_page, 'Get funding and support to set up a digital education platform')
  end

  scenario 'user is a parent,carer or student would like to find out how to use their device' do
    when_i_visit_the_home_page
    and_i_click_on_guides_for_parents_link
    then_i_should_see_the_guides_for_parents_carers_students_page
    and_the_page_title_should_be_set(@guides_parents_carers_students_page, 'Guides for parents, guardians, pupils and students')
  end

private

  def when_i_visit_the_home_page
    visit '/'
    @home_page ||= PageObjects::Pages::HomePage.new
  end

  def then_i_should_see_the_service_name
    expect(@home_page.page_heading).to have_text(I18n.t('service_name'))
  end

  def and_i_click_on_free_training_and_free_support_link
    @home_page.edtech_landing_page_link.click
  end

  def and_i_click_on_get_funding_to_setup_platforms_link
    @home_page.digital_platforms_page_link.click
  end

  def and_i_click_on_guides_for_parents_link
    @home_page.guides_parents_carers_students_link.click
  end

  def then_i_should_see_the_edtech_programme_page
    @edtech_landing_page ||= PageObjects::LandingPages::EdtechDemonstratorProgrammePage.new
    expect(@edtech_landing_page).to be_displayed
  end

  def then_i_should_see_the_digital_platforms_page
    @digital_platforms_page ||= PageObjects::LandingPages::DigitalPlatformsPage.new
    expect(@digital_platforms_page).to be_displayed
  end

  def then_i_should_see_the_guides_for_parents_carers_students_page
    @guides_parents_carers_students_page ||= PageObjects::GuidesForParentsCarersStudents::IndexPage.new
    expect(@guides_parents_carers_students_page).to be_displayed
  end

  def and_the_page_title_should_be_set(current_page, title)
    expect(current_page)
      .to have_title "#{title} - Get help with technology - GOV.UK"
  end
end
