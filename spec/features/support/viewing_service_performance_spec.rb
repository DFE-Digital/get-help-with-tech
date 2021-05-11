require 'rails_helper'

RSpec.describe 'Viewing service performance', type: :feature do
  it 'DfE users see service stats about sign-ins and who orders' do
    given_there_have_been_sign_ins_from_users_of_devolved_schools_and_responsible_bodies

    when_i_sign_in_as_a_dfe_user
    and_i_follow_links_to_the_service_performance_page

    then_i_see_sign_in_stats_about_devolved_schools_and_responsible_bodies
  end

  it 'DfE users see service stats about who orders' do
    given_there_devolved_schools_and_centrally_managed_schools

    when_i_sign_in_as_a_dfe_user
    and_i_follow_links_to_the_service_performance_page

    then_i_see_stats_about_who_orders
  end

  it 'DfE users see service stats about devices' do
    given_there_are_available_shipped_and_remaining_devices

    when_i_sign_in_as_a_dfe_user
    and_i_follow_links_to_the_service_performance_page
    and_i_select_the_devices_tab

    then_i_see_stats_about_devices
    then_i_see_stats_about_devolved_schools_devices
    then_i_see_stats_about_responsible_bodies_managed_schools_devices
  end

  it 'DfE users see service stats about extra mobile data requests' do
    given_some_extra_mobile_data_requests_have_been_made

    when_i_sign_in_as_a_dfe_user
    and_i_follow_links_to_the_service_performance_page
    and_i_select_the_mno_tab

    then_i_see_stats_about_extra_mobile_data_requests
  end

  it 'DfE users can query for completions between given dates' do
    given_there_are_some_completion_events

    when_i_sign_in_as_a_dfe_user
    and_i_follow_links_to_the_service_performance_page
    and_i_select_the_mno_tab
    then_i_see_the_number_of_completions_up_to_the_current_date

    when_i_enter_from_and_to_dates
    and_click_calculate
    then_i_see_the_correct_number
    and_i_see_the_dates_i_entered_in_govuk_format
  end

  it 'DfE users see service stats about routers' do
    given_there_are_available_shipped_and_remaining_routers

    when_i_sign_in_as_a_dfe_user
    and_i_follow_links_to_the_service_performance_page
    and_i_select_the_routers_tab

    then_i_see_stats_about_routers
    then_i_see_stats_about_devolved_schools_routers
    then_i_see_stats_about_responsible_bodies_managed_schools_routers
  end

  def given_there_have_been_sign_ins_from_users_of_devolved_schools_and_responsible_bodies
    devolved_schools = create_list(:school, 10, :manages_orders)
    responsible_bodies = [create_list(:local_authority, 5, :manages_centrally), create_list(:trust, 5, :manages_centrally)].flatten
    devolved_schools[0..1].each { |s| s.users << create(:user, :signed_in_before) }
    responsible_bodies[0..2].each { |rb| create(:user, :signed_in_before, responsible_body: rb) }
  end

  def given_there_devolved_schools_and_centrally_managed_schools
    create_list(:school, 2, :manages_orders)
    create_list(:school, 4, :centrally_managed)
  end

  def given_there_are_available_shipped_and_remaining_devices
    devolved_schools = create_list(:school, 5, :manages_orders, :with_std_device_allocation)
    managed_schools = create_list(:school, 5, :centrally_managed, :with_std_device_allocation)

    devolved_schools[0].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 30)
    devolved_schools[1].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 10)
    devolved_schools[2].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 10)
    devolved_schools[3].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 10)
    devolved_schools[4].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 0)

    managed_schools[0].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 30)
    managed_schools[1].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 30)
    managed_schools[2].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 10)
    managed_schools[3].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 0)
    managed_schools[4].std_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 0)
  end

  def given_there_are_available_shipped_and_remaining_routers
    devolved_schools = create_list(:school, 5, :manages_orders, :with_coms_device_allocation)
    managed_schools = create_list(:school, 5, :centrally_managed, :with_coms_device_allocation)

    devolved_schools[0].coms_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 30)
    devolved_schools[1].coms_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 10)
    devolved_schools[2].coms_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 10)
    devolved_schools[3].coms_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 10)
    devolved_schools[4].coms_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 0)

    managed_schools[0].coms_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 30)
    managed_schools[1].coms_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 30)
    managed_schools[2].coms_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 10)
    managed_schools[3].coms_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 0)
    managed_schools[4].coms_device_allocation.update!(allocation: 30, cap: 30, devices_ordered: 0)
  end

  def given_some_extra_mobile_data_requests_have_been_made
    ee = create(:mobile_network, brand: 'EE')
    three = create(:mobile_network, brand: 'Three')
    virgin = create(:mobile_network, brand: 'Virgin')
    rb = create(:local_authority)
    rb_requester = create(:user, responsible_body: rb)
    create_list(:school, 3, :centrally_managed)
    schools = create_list(:school, 3, :manages_orders)
    school_requester = create(:user)
    schools[0].users << school_requester

    create_list(:extra_mobile_data_request, 1,
                status: :new,
                mobile_network: virgin,
                responsible_body: rb,
                created_by_user: rb_requester)
    create_list(:extra_mobile_data_request, 3,
                status: :in_progress,
                mobile_network: ee,
                responsible_body: rb,
                created_by_user: rb_requester)
    create_list(:extra_mobile_data_request, 4,
                status: :complete,
                mobile_network: three,
                school: schools[0],
                created_by_user: school_requester)
    create_list(:extra_mobile_data_request, 1,
                status: :cancelled,
                mobile_network: virgin,
                responsible_body: rb,
                created_by_user: rb_requester)
  end

  def given_there_are_some_completion_events
    create_list(:reportable_event, 4, :extra_mobile_data_request_completion, event_time: 2.weeks.ago)
    create_list(:reportable_event, 2, :extra_mobile_data_request_completion, event_time: 1.week.ago)
    create_list(:reportable_event, 1, :extra_mobile_data_request_completion, event_time: 2.hours.ago)
  end

  def then_i_see_the_number_of_completions_up_to_the_current_date
    within('#mno') do
      expect(page).to have_text "7 requests completed up to #{Time.zone.now.localtime.to_s(:govuk_date_and_time)}".gsub(/(\s)+/, '\1')
    end
  end

  def when_i_enter_from_and_to_dates
    within('#mno') do
      find('summary', text: 'Calculate completions for different dates').click
      fill_in 'From', with: (Time.zone.now - 10.days).localtime.to_date.iso8601
      fill_in 'To', with: '2 days ago'
    end
  end

  def and_click_calculate
    click_on('Calculate')
  end

  def then_i_see_the_correct_number
    within('#mno') do
      expect(page).to have_text '2 requests completed'
    end
  end

  def and_i_see_the_dates_i_entered_in_govuk_format
    within('#mno') do
      expect(page).to have_text "requests completed between #{(Time.zone.now - 10.days).localtime.to_date.to_s(:govuk_date)}".gsub(/(\s)+/, '\1')
      expect(page).to have_text "and #{(Time.zone.now - 2.days).localtime.to_s(:govuk_date_and_time)}".gsub(/(\s)+/, '\1')
    end
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def and_i_follow_links_to_the_service_performance_page
    click_link 'Service performance'
  end

  def and_i_select_the_devices_tab
    click_on 'Devices'
  end

  def and_i_select_the_mno_tab
    click_on 'MNO'
  end

  def and_i_select_the_routers_tab
    click_on 'Routers'
  end

  def then_i_see_sign_in_stats_about_devolved_schools_and_responsible_bodies
    within('#service') do
      expect(page).to have_selector('h2', text: 'Sign-ins')
      expect(page).to have_text('20% of devolved schools signed in (2 out of 10)')
      expect(page).to have_text('15% of responsible bodies signed in (3 out of 20)')
    end
  end

  def then_i_see_stats_about_who_orders
    within('#service') do
      expect(page).to have_selector('h2', text: 'Who orders')
      expect(page).to have_text('2 schools order their own devices')
      expect(page).to have_text('4 schools are managed centrally')
    end
  end

  def then_i_see_stats_about_devices
    within('#devices') do
      expect(page).to have_selector('h2', text: 'Devices')
      expect(page).to have_text('300 total devices available')
      expect(page).to have_text('130 devices shipped')
      expect(page).to have_text('170 remaining')
    end
  end

  def then_i_see_stats_about_devolved_schools_devices
    within('#devices') do
      expect(page).to have_selector('h3', text: 'Schools')
      expect(page).to have_text('5 devolved schools')
      expect(page).to have_text('20% ordered their full allocation (1 out of 5)')
      expect(page).to have_text('60% ordered but have devices left (3 out of 5)')
      expect(page).to have_text('20% have not ordered (1 out of 5)')
    end
  end

  def then_i_see_stats_about_responsible_bodies_managed_schools_devices
    within('#devices') do
      expect(page).to have_selector('h3', text: 'Responsible bodies')
      expect(page).to have_text('5 responsible bodies managing orders centrally on behalf of 5 schools')
      expect(page).to have_text('40% ordered their full allocation (2 out of 5)')
      expect(page).to have_text('20% ordered but have devices left (1 out of 5)')
      expect(page).to have_text('40% have not ordered (2 out of 5)')
    end
  end

  def then_i_see_stats_about_extra_mobile_data_requests
    within('#mno') do
      expect(page).to have_selector('h2', text: 'Mobile data requests')
      expect(page).to have_text('9 requests')
      expect(page).to have_text('1 new')
      expect(page).to have_text('3 in progress')
      expect(page).to have_text('1 not valid')
      expect(page).to have_text('4 completed')

      expect(page).to have_text('EE 0 3 0 0 3')
      expect(page).to have_text('Virgin 1 0 0 1 2')
      expect(page).to have_text('Three 0 0 4 0 4')

      expect(page).to have_selector('h3', text: 'Who has made requests')
      expect(page).to have_text('1 devolved schools (out of 3)')
      expect(page).to have_text('1 responsible bodies managing orders centrally (out of 3, and on behalf of 3 schools)')
    end
  end

  def then_i_see_stats_about_routers
    within('#routers') do
      expect(page).to have_selector('h2', text: 'Routers')
      expect(page).to have_text('300 total routers available')
      expect(page).to have_text('130 routers shipped')
      expect(page).to have_text('170 routers remaining')
    end
  end

  def then_i_see_stats_about_devolved_schools_routers
    within('#routers') do
      expect(page).to have_selector('h3', text: 'Schools')
      expect(page).to have_text('5 schools that have a router allocation')
      expect(page).to have_text('20% ordered their full allocation (1 out of 5)')
      expect(page).to have_text('60% ordered but have routers left (3 out of 5)')
      expect(page).to have_text('20% have not ordered (1 out of 5)')
    end
  end

  def then_i_see_stats_about_responsible_bodies_managed_schools_routers
    within('#routers') do
      expect(page).to have_selector('h3', text: 'Responsible bodies')
      expect(page).to have_text('5 responsible bodies managing centrally have a school with a router allocation')
      expect(page).to have_text('40% ordered their full allocation (2 out of 5)')
      expect(page).to have_text('20% ordered but have routers left (1 out of 5)')
      expect(page).to have_text('40% have not ordered (2 out of 5)')
    end
  end
end
