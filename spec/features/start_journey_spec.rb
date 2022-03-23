require 'rails_helper'

RSpec.feature 'View pages', type: :feature do
  scenario 'Root URL should be the home page' do
    when_i_visit_the_home_page
    then_i_should_see_the_service_name
  end

private

  def when_i_visit_the_home_page
    visit '/'
    @home_page ||= PageObjects::Pages::HomePage.new
  end

  def then_i_should_see_the_service_name
    expect(@home_page.page_heading).to have_text(I18n.t('service_name'))
  end
end
