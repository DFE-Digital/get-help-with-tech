require 'rails_helper'

RSpec.describe 'Updating addresses' do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school) }
  let(:school_page) { PageObjects::Support::SchoolDetailsPage.new }

  before do
    sign_in_as support_user
  end

  it 'opting out a school' do
    given_a_school_that_is_opted_in
    when_support_user_visits_school_page
    then_they_see('Yes, receiving communications')

    when_they_click('Change communications preference')
    then_they_see('Change communication preference')
    and_no_opt_in_should_be_checked

    when_they_choose('Opt out and no longer receive communications')
    and_click('Save')
    then_they_should_see_the_school_page
    and_they_see('No, opted out of receiving communications')
  end

  it 'opting in a school' do
    given_a_school_that_is_opted_out
    when_support_user_visits_school_page
    then_they_see('No, opted out of receiving communications')

    when_they_click('Change communications preference')
    then_they_see('Change communication preference')
    and_yes_opt_out_should_be_checked

    when_they_choose('Opt in and receive communcations')
    and_click('Save')
    then_they_should_see_the_school_page
    and_they_see('Yes, receiving communications')
  end

  def given_a_school_that_is_opted_in
    @school = create(:school)
  end

  def given_a_school_that_is_opted_out
    @school = create(:school, opted_out_of_comms_at: 1.day.ago)
  end

  def when_support_user_visits_school_page
    school_page.load(urn: @school.urn)
  end

  def then_they_see(string)
    expect(page).to have_content(string)
  end

  def when_they_click(string)
    page.click_link(string)
  end

  def and_no_opt_in_should_be_checked
    expect(page.find_field('school-opt-out-0-field')).to be_checked
  end

  def and_yes_opt_out_should_be_checked
    expect(page.find_field('school-opt-out-1-field')).to be_checked
  end

  def when_they_choose(string)
    page.choose(string)
  end

  def and_click(string)
    page.click_button(string)
  end

  def then_they_should_see_the_school_page
    expect(school_page).to be_displayed
  end

  def and_they_see(string)
    then_they_see(string)
  end
end
