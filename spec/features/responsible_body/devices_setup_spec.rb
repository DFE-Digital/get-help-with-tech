require 'rails_helper'

RSpec.feature 'Setting up the devices ordering' do
  let(:responsible_body_schools_page) { PageObjects::ResponsibleBody::SchoolsPage.new }
  let(:responsible_body_school_page) { PageObjects::ResponsibleBody::SchoolPage.new }

  context 'as a local authority user' do
    let(:responsible_body) { create(:local_authority) }
    let(:local_authority_user) { create(:local_authority_user, responsible_body: responsible_body) }
    let(:school_with_no_headteacher) { create(:school, :la_maintained, :secondary, responsible_body: responsible_body, name: 'School with no headteacher') }

    before do
      stub_computacenter_outgoing_api_calls

      @zebra_school = create(:school, :la_maintained, :secondary,
                             responsible_body: responsible_body,
                             urn: '123321',
                             name: 'Zebra Secondary School')
      @aardvark_school = create(:school, :la_maintained, :primary,
                                responsible_body: responsible_body,
                                urn: '456654',
                                name: 'Aardvark Primary School',
                                laptops: [42, 42, 42])

      create(:school_contact,
             school: @aardvark_school,
             role: :headteacher,
             title: 'Executive Head',
             full_name: 'Anne Jones',
             email_address: 'anne.jones@aardvark.sch.uk')
      create(:school_contact,
             school: @zebra_school,
             role: :headteacher,
             title: 'Headteacher',
             full_name: 'Jane Smith',
             email_address: 'jane.smith@zebra.sch.uk')

      sign_in_as local_authority_user
    end

    scenario 'devolving device ordering mostly to schools' do
      when_i_follow_the_get_devices_link
      then_i_see_guidance_for_a_local_authority
      and_i_continue_through_the_guidance
      and_i_choose_ordering_through_schools_which_is_recommended
      and_i_continue_after_choosing_ordering_through_schools
      then_i_see_a_list_of_the_schools_i_am_responsible_for
      and_each_school_shows_the_devices_ordered_or_zero_if_no_orders
      and_the_list_shows_that_schools_will_place_all_orders
      and_each_school_needs_a_contact

      when_i_visit_the_first_school
      then_i_see_the_details_of_the_first_school
      and_that_the_school_orders_devices

      when_i_select_to_contact_the_headteacher
      then_i_see_a_confirmation_and_the_headteacher_as_the_contact
      and_the_status_reflects_that_the_school_has_been_contacted
      and_the_headteacher_has_been_invited_to_the_service

      when_i_follow_the_link_to_the_next_school
      then_i_see_the_details_of_the_second_school
      and_i_do_not_see_a_next_school_link

      when_i_select_to_contact_someone_else_and_save_their_details
      then_i_see_a_confirmation_and_the_someone_else_as_the_contact
      and_the_status_reflects_that_the_school_has_been_contacted
      and_the_school_contact_has_been_invited_to_the_service
    end

    scenario 'devolving device ordering mostly centrally' do
      when_i_follow_the_get_devices_link
      then_i_see_guidance_for_a_local_authority
      and_i_continue_through_the_guidance
      and_i_choose_ordering_centrally
      then_i_see_a_list_of_the_schools_i_am_responsible_for
      and_each_school_shows_the_devices_ordered_or_zero_if_no_orders
      and_the_list_shows_that_the_responsible_body_will_place_all_orders
      and_each_school_needs_information

      when_i_visit_the_first_school
      then_i_see_the_details_of_the_first_school
      and_that_the_local_authority_orders_devices
      and_i_dont_see_a_link_to_change_who_orders_devices
    end

    scenario 'submitting the form without choosing an option shows an error' do
      visit responsible_body_devices_who_will_order_edit_path
      click_on 'Continue'
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content('There is a problem')
    end

    scenario 'when the school has no headteacher contact (bug #537)' do
      given_there_is_a_school_with_no_headteacher
      when_i_follow_the_get_devices_link
      and_i_continue_through_the_guidance
      and_i_choose_ordering_through_schools_which_is_recommended
      and_i_continue_after_choosing_ordering_through_schools
      when_i_visit_a_school_which_has_no_headteacher
      then_i_do_not_see_the_options_to_contact_the_headteacher_or_someone_else
      and_i_see_the_form_to_nominate_someone_to_contact
      when_i_fill_in_details_of_a_contact_and_save_their_details
      then_i_see_a_confirmation_and_the_someone_else_as_the_contact
      and_the_status_reflects_that_the_school_has_been_contacted
    end

    scenario 'when the school has no standard device allocation' do
      given_there_is_a_school_with_no_standard_device_allocation
      when_i_follow_the_get_devices_link
      and_i_continue_through_the_guidance
      and_i_choose_ordering_through_schools_which_is_recommended
      and_i_continue_after_choosing_ordering_through_schools
      when_i_click_on_the_name_of_a_school_which_has_no_standard_device_allocation
      then_i_see_guidance_about_why_there_is_no_allocation
      and_in_the_allocation_guidance_we_ask_for_information
      when_i_select_to_contact_someone_else_and_save_their_details
      then_i_see_the_allocation_guidance_without_the_we_need_information_section
    end
  end

  context 'as a trust user' do
    let(:responsible_body) { create(:trust, :multi_academy_trust) }
    let(:trust_user) { create(:trust_user, responsible_body: responsible_body) }

    before do
      stub_computacenter_outgoing_api_calls

      @koala_academy = create(:school, :academy, :secondary,
                              responsible_body: responsible_body,
                              name: 'Koala Academy')

      @pangolin_academy = create(:school, :academy, :primary,
                                 responsible_body: responsible_body,
                                 name: 'Pangolin Primary Academy')

      sign_in_as trust_user
    end

    scenario 'devolving device ordering mostly to schools' do
      when_i_follow_the_get_devices_link
      then_i_see_guidance_for_a_trust
      and_i_continue_through_the_guidance
      and_i_choose_ordering_through_schools_which_is_not_explicitly_recommended
      and_i_continue_after_choosing_ordering_through_schools
      then_i_see_a_list_of_the_academies_i_am_responsible_for
    end

    scenario 'devolving device ordering mostly centrally' do
      when_i_follow_the_get_devices_link
      then_i_see_guidance_for_a_trust
      and_i_continue_through_the_guidance
      and_i_choose_ordering_centrally
      then_i_see_a_list_of_the_academies_i_am_responsible_for
    end
  end

  def when_i_follow_the_get_devices_link
    visit responsible_body_devices_path
  end

  def and_i_follow_the_your_schools_link
    click_on 'Your schools'
  end

  def then_i_see_guidance_for_a_trust
    expect(page).to have_content 'Decide if schools and colleges can order their own devices'
    expect(page).to have_content 'If you let schools and colleges place orders you’ll'
  end

  def then_i_see_guidance_for_a_local_authority
    expect(page).to have_content 'Decide if schools and colleges can order their own devices'
    expect(page).to have_content 'We recommend letting schools and colleges place orders'
  end

  def and_i_continue_through_the_guidance
    click_on 'Continue'
    expect(page).to have_content 'Who will place orders for laptops?'
  end

  def and_i_choose_ordering_through_schools_which_is_not_explicitly_recommended
    choose 'Most schools and colleges will place their own orders'
  end

  def and_i_choose_ordering_through_schools_which_is_recommended
    choose 'Most schools and colleges will place their own orders (recommended)'
  end

  def and_i_continue_after_choosing_ordering_through_schools
    click_on 'Continue'
    expect(page).to have_http_status(:ok)
    expect(page).to have_content('Each school or college will place their own orders')
    expect(page).to have_content('We’ve saved your choice')
    click_on 'See your schools and colleges'
  end

  def and_i_choose_ordering_centrally
    choose 'Most orders will be placed centrally'
    click_on 'Continue'
    expect(page).to have_http_status(:ok)
    expect(page).to have_content('We’ve saved your choice')
    expect(page).to have_content('Orders will be placed centrally')
    click_on 'See your schools and colleges'
  end

  def then_i_see_a_list_of_the_schools_i_am_responsible_for
    expect(page).to have_content('Your schools')
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[0].title)
      .to have_content('Aardvark Primary School (456654) Primary school')
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[1].title)
      .to have_content('Zebra Secondary School (123321) Secondary school')
  end

  def then_i_see_a_list_of_the_academies_i_am_responsible_for
    expect(page).to have_content('Your schools')
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[0].title)
      .to have_content('Koala Academy')
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[1].title)
      .to have_content('Pangolin Primary Academy')
  end

  def and_each_school_shows_the_devices_ordered_or_zero_if_no_orders
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[0].devices_ordered).to have_content('42')
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[1].devices_ordered).to have_content('0')
  end

  def and_each_school_needs_a_contact
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[0].text).to have_content('Needs a contact')
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[1].text).to have_content('Needs a contact')
  end

  def and_each_school_needs_information
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[0].text).to have_content('Needs information')
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[1].text).to have_content('Needs information')
  end

  def given_the_responsible_body_has_decided_to_order_centrally
    responsible_body.update!(default_who_will_order_devices_for_schools: 'school')
    responsible_body.schools.each { |school| SchoolSetWhoManagesOrdersService.new(school, :school).call }
  end

  def when_i_visit_the_responsible_body_homepage
    visit responsible_body_home_path
  end

  def and_the_list_shows_that_schools_will_place_all_orders
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[0].who_will_order_devices).to have_content('School')
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[1].who_will_order_devices).to have_content('School')
  end

  def and_the_list_shows_that_the_responsible_body_will_place_all_orders
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[0].who_will_order_devices).to have_content('Local authority')
    expect(responsible_body_schools_page.cannot_order_yet_school_rows[1].who_will_order_devices).to have_content('Local authority')
  end

  def when_i_visit_the_first_school
    visit responsible_body_devices_school_path(@aardvark_school.urn)
  end

  def given_there_is_a_school_with_no_headteacher
    school_with_no_headteacher
  end

  def when_i_visit_a_school_which_has_no_headteacher
    visit responsible_body_devices_school_path(school_with_no_headteacher.urn)
  end

  def then_i_do_not_see_the_options_to_contact_the_headteacher_or_someone_else
    expect(responsible_body_school_page).not_to have_field('Someone else')
  end

  def and_i_see_the_form_to_nominate_someone_to_contact
    expect(responsible_body_school_page).to have_field('Name')
    expect(responsible_body_school_page).to have_field('Email address')
    expect(responsible_body_school_page).to have_field('Telephone number')
  end

  def when_i_fill_in_details_of_a_contact_and_save_their_details
    fill_in 'Name', with: 'Bob Leigh'
    fill_in 'Email address', with: 'bob.leigh@sharedservices.co.uk'
    fill_in 'Telephone number', with: '020 123456'

    click_on 'Save'
  end

  def then_i_see_the_details_of_the_first_school
    expect(responsible_body_school_page).to have_content(@aardvark_school.name)
    expect(responsible_body_school_page.school_details).to have_content('42 devices')
    expect(responsible_body_school_page.school_details).to have_content('Primary school')
  end

  def then_i_see_the_details_of_the_second_school
    expect(responsible_body_school_page).to have_content(@zebra_school.name)
    expect(responsible_body_school_page.school_details).to have_content('0 devices')
    expect(responsible_body_school_page.school_details).to have_content('Secondary school')
  end

  def and_that_the_school_orders_devices
    expect(responsible_body_school_page.school_details).to have_content('Needs a contact')
    expect(responsible_body_school_page.school_details).to have_content('The school or college ordered devices')
  end

  def and_that_the_local_authority_orders_devices
    expect(responsible_body_school_page.school_details).to have_content('Needs information')
    expect(responsible_body_school_page.school_details).to have_content('The local authority ordered devices')
  end

  def and_that_i_am_prompted_to_choose_who_to_contact_at_the_school
    expect(responsible_body_school_page).to have_content('Who can we contact at the school?')
  end

  def when_i_select_to_contact_the_headteacher
    choose 'Executive Head'
    click_on 'Save'
  end

  def then_i_see_a_confirmation_and_the_headteacher_as_the_contact
    expect(page).to have_content('Saved. We’ve emailed anne.jones@aardvark.sch.uk')
    expect(responsible_body_school_page.school_details).to have_content('Executive Head: Anne Jones')
    expect(responsible_body_school_page.school_details).to have_content('anne.jones@aardvark.sch.uk')
  end

  def and_the_status_reflects_that_the_school_has_been_contacted
    expect(responsible_body_school_page.school_details).to have_content('School contacted')
  end

  def and_the_headteacher_has_been_invited_to_the_service
    open_email('anne.jones@aardvark.sch.uk')
    expect(current_email).to be_present
    expect(current_email.header('template-id')).to eq(Settings.govuk_notify.templates.devices.school_nominated_contact)
    expect(User.exists?(email_address: 'anne.jones@aardvark.sch.uk')).to be_truthy
  end

  def and_the_school_contact_has_been_invited_to_the_service
    open_email('bob.leigh@sharedservices.co.uk')
    expect(current_email).to be_present
    expect(current_email.header('template-id')).to eq(Settings.govuk_notify.templates.devices.school_nominated_contact)
    expect(User.exists?(email_address: 'bob.leigh@sharedservices.co.uk')).to be_truthy
  end

  def when_i_follow_the_link_to_the_next_school
    click_on 'go to the next school'
  end

  def and_i_do_not_see_a_next_school_link
    expect(page).not_to have_link('go to the next school')
  end

  def when_i_select_to_contact_someone_else_and_save_their_details
    choose 'Someone else'

    fill_in 'Name', with: 'Bob Leigh'
    fill_in 'Email address', with: 'bob.leigh@sharedservices.co.uk'
    fill_in 'Telephone number', with: '020 123456'

    click_on 'Save'
  end

  def then_i_see_a_confirmation_and_the_someone_else_as_the_contact
    expect(page).to have_content('Saved. We’ve emailed bob.leigh@sharedservices.co.uk')
    expect(responsible_body_school_page.school_details).to have_content('Bob Leigh')
    expect(responsible_body_school_page.school_details).to have_content('bob.leigh@sharedservices.co.uk')
    expect(responsible_body_school_page.school_details).to have_content('020 123456')
  end

  def and_i_dont_see_a_link_to_change_who_orders_devices
    expect(page).not_to have_link('Change who ordered')
  end

  def and_i_see_a_link_to_change_who_orders_devices
    expect(page).to have_link('Change who ordered')
  end

  def when_i_follow_the_change_who_will_order_link
    click_on 'Change who ordered'
  end

  def then_i_am_prompted_to_choose_who_orders_devices_for_the_school
    expect(page).to have_content('Who will place orders for laptops?')
  end

  def when_i_select_the_school_to_order_devices
    choose('The school will place their own orders')
    click_on 'Continue'
  end

  def when_i_select_orders_will_be_placed_centrally
    choose('Orders will be placed centrally')
    click_on 'Continue'
  end

  def given_there_is_a_school_with_no_standard_device_allocation
    expect(@zebra_school).not_to have_allocation(:laptop)
  end

  def when_i_click_on_the_name_of_a_school_which_has_no_standard_device_allocation
    visit responsible_body_devices_school_path(@zebra_school.urn)
  end

  def then_i_see_guidance_about_why_there_is_no_allocation
    expect(responsible_body_school_page).to have_content('This school has no allocation')
  end

  def and_in_the_allocation_guidance_we_ask_for_information
    expect(responsible_body_school_page).to have_content('We still need some information')
  end

  def then_i_see_the_allocation_guidance_without_the_we_need_information_section
    expect(responsible_body_school_page).to have_content('This school has no allocation')
    expect(responsible_body_school_page).not_to have_content('We still need some information')
  end
end
