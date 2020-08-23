require 'rails_helper'

RSpec.feature 'Setting up the devices ordering' do
  let(:responsible_body) { create(:local_authority, in_devices_pilot: true) }
  let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body) }
  let(:responsible_body_schools_page) { PageObjects::ResponsibleBody::SchoolsPage.new }
  let(:responsible_body_school_page) { PageObjects::ResponsibleBody::SchoolPage.new }

  before do
    _zebra_school = create(:school, :la_maintained, :secondary,
                           responsible_body: responsible_body,
                           name: 'Zebra Secondary School')
    @aardvark_school = create(:school, :la_maintained, :primary,
                              responsible_body: responsible_body,
                              name: 'Aardvark Primary School')

    create(:school_device_allocation, school: @aardvark_school, device_type: 'std_device', allocation: 42)
    sign_in_as rb_user
  end

  scenario 'devolving device ordering mostly to schools' do
    when_i_follow_the_get_devices_link
    and_i_continue_through_the_guidance
    and_i_choose_ordering_through_schools
    then_i_see_a_list_of_the_schools_i_am_responsible_for
    and_each_school_shows_the_devices_allocated_or_zero_if_no_allocation
    and_the_list_shows_that_schools_will_place_all_orders
    and_each_school_needs_a_contact

    when_i_click_on_a_school_name
    then_i_see_the_details_of_the_school
    and_that_the_school_orders_devices
  end

  scenario 'devolving device ordering mostly centrally' do
    when_i_follow_the_get_devices_link
    and_i_continue_through_the_guidance
    and_i_choose_ordering_centrally
    then_i_see_a_list_of_the_schools_i_am_responsible_for
    and_each_school_shows_the_devices_allocated_or_zero_if_no_allocation
    and_the_list_shows_that_the_responsible_body_will_place_all_orders
    and_each_school_needs_information

    when_i_click_on_a_school_name
    then_i_see_the_details_of_the_school
    and_that_the_local_authority_orders_devices
  end

  scenario 'submitting the form without choosing an option shows an error' do
    visit responsible_body_devices_who_will_order_edit_path
    click_on 'Continue'
    expect(page).to have_http_status(:unprocessable_entity)
    expect(page).to have_content('There is a problem')
  end

  scenario 'changing the settings for each school after making the choice about who will order' do
    given_the_responsible_body_has_decided_to_order_centrally
    when_i_visit_the_responsible_body_homepage
    when_i_follow_the_get_devices_link
    then_i_see_a_list_of_the_schools_i_am_responsible_for
  end

  def when_i_follow_the_get_devices_link
    click_on 'Get laptops and tablets'
  end

  def and_i_continue_through_the_guidance
    expect(page).to have_content 'Schools can now order their own devices'
    expect(page).to have_link 'Continue'
    click_on 'Continue'
    expect(page).to have_content 'Who will order a school’s laptops and tablets?'
    expect(page).to have_field 'Most schools will manage their own orders (recommended)'
  end

  def and_i_choose_ordering_through_schools
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
    expect(responsible_body_schools_page.school_rows[0].title)
      .to have_content('Aardvark Primary School Primary school')
    expect(responsible_body_schools_page.school_rows[1].title)
      .to have_content('Zebra Secondary School Secondary school')
  end

  def and_each_school_needs_a_contact
    expect(responsible_body_schools_page.school_rows[0].status).to have_content('Needs a contact')
    expect(responsible_body_schools_page.school_rows[1].status).to have_content('Needs a contact')
  end

  def and_each_school_needs_information
    expect(responsible_body_schools_page.school_rows[0].status).to have_content('Needs information')
    expect(responsible_body_schools_page.school_rows[1].status).to have_content('Needs information')
  end

  def and_each_school_shows_the_devices_allocated_or_zero_if_no_allocation
    expect(responsible_body_schools_page.school_rows[0].allocation).to have_content('42')
    expect(responsible_body_schools_page.school_rows[1].allocation).to have_content('0')
  end

  def given_the_responsible_body_has_decided_to_order_centrally
    responsible_body.update!(who_will_order_devices: 'schools')
    responsible_body.schools.each do |school|
      school.create_preorder_information!(who_will_order_devices: 'school')
    end
  end

  def when_i_visit_the_responsible_body_homepage
    visit responsible_body_home_path
  end

  def and_the_list_shows_that_schools_will_place_all_orders
    expect(responsible_body_schools_page.school_rows[0].who_will_order_devices).to have_content('School')
    expect(responsible_body_schools_page.school_rows[1].who_will_order_devices).to have_content('School')
  end

  def and_the_list_shows_that_the_responsible_body_will_place_all_orders
    expect(responsible_body_schools_page.school_rows[0].who_will_order_devices).to have_content('Local authority')
    expect(responsible_body_schools_page.school_rows[1].who_will_order_devices).to have_content('Local authority')
  end

  def when_i_click_on_a_school_name
    click_on @aardvark_school.name
  end

  def then_i_see_the_details_of_the_school
    expect(responsible_body_school_page).to have_content(@aardvark_school.name)
    expect(responsible_body_school_page.school_details).to have_content('42 devices')
    expect(responsible_body_school_page.school_details).to have_content('Primary school')
  end

  def and_that_the_school_orders_devices
    expect(responsible_body_school_page.school_details).to have_content('Needs a contact')
    expect(responsible_body_school_page.school_details).to have_content('The school orders devices')
  end

  def and_that_the_local_authority_orders_devices
    expect(responsible_body_school_page.school_details).to have_content('Needs information')
    expect(responsible_body_school_page.school_details).to have_content('The local authority orders devices')
  end
end
