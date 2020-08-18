require 'rails_helper'

RSpec.feature 'Setting up the devices ordering' do
  let(:responsible_body) { create(:local_authority, in_devices_pilot: true) }
  let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body) }
  let(:responsible_body_schools_page) { PageObjects::ResponsibleBody::SchoolsPage.new }

  before do
    create(:school, responsible_body: responsible_body, name: 'Zebra Secondary School')
    create(:school, responsible_body: responsible_body, name: 'Aardvark Primary School')
    sign_in_as rb_user
  end

  scenario 'devolving device ordering mostly to schools' do
    when_i_follow_the_get_devices_link
    and_i_continue_through_the_guidance
    and_i_choose_ordering_through_schools
    then_i_see_a_list_of_the_schools_i_am_responsible_for
  end

  scenario 'devolving device ordering mostly centrally' do
    when_i_follow_the_get_devices_link
    and_i_continue_through_the_guidance
    and_i_choose_ordering_centrally
    then_i_see_a_list_of_the_schools_i_am_responsible_for
  end

  scenario 'submitting the form without choosing an option shows an error' do
    visit responsible_body_devices_who_will_order_edit_path
    click_on 'Continue'
    expect(page).to have_http_status(:unprocessable_entity)
    expect(page).to have_content('There is a problem')
  end

  def when_i_follow_the_get_devices_link
    click_on 'Get devices'
    expect(page).to have_content 'Schools can now order their own devices'
    expect(page).to have_link 'Continue'
  end

  def and_i_continue_through_the_guidance
    click_on 'Continue'
    expect(page).to have_content 'Who will order a school’s laptops and tablets?'
    expect(page).to have_field 'Most schools will manage their own orders (recommended)'
  end

  def and_i_choose_ordering_through_schools
    visit responsible_body_devices_who_will_order_edit_path
    choose 'Most schools will manage their own orders (recommended)'
    click_on 'Continue'
    expect(page).to have_http_status(:ok)
    expect(page).to have_content('We’ve set each school as managing their own orders')
    click_on 'Go to your list of schools'
  end

  def and_i_choose_ordering_centrally
    choose 'Most orders will be managed centrally'
    click_on 'Continue'
    expect(page).to have_http_status(:ok)
    expect(page).to have_content('We’ve set each school as having their orders managed centrally')
    click_on 'Go to your list of schools'
  end

  def then_i_see_a_list_of_the_schools_i_am_responsible_for
    expect(page).to have_content('2 schools')
    expect(responsible_body_schools_page.school_rows[0]).to have_content('Aardvark Primary School')
    expect(responsible_body_schools_page.school_rows[1]).to have_content('Zebra Secondary School')
  end
end
