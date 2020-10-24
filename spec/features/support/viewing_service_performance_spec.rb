require 'rails_helper'

RSpec.feature 'Viewing service performance', type: :feature do
  let(:local_authority) { create(:local_authority, :in_connectivity_pilot, :in_devices_pilot) }

  scenario 'DfE users see service stats about responsible body user engagement' do
    given_there_have_been_sign_ins_from_responsible_body_and_mno_users

    when_i_sign_in_as_a_dfe_user

    then_i_see_stats_about_responsible_body_user_engagement
  end

  scenario 'DfE users see service stats about extra mobile data requests' do
    given_some_extra_mobile_data_requests_have_been_made

    when_i_sign_in_as_a_dfe_user

    then_i_see_stats_about_extra_mobile_data_requests
  end

  def given_there_have_been_sign_ins_from_responsible_body_and_mno_users
    create(:mno_user, :signed_in_before)
    create_list(:local_authority_user, 2, :signed_in_before, responsible_body: local_authority)
  end

  def given_some_extra_mobile_data_requests_have_been_made
    ee = create(:mobile_network, brand: 'EE')
    three = create(:mobile_network, brand: 'Three')
    virgin = create(:mobile_network, brand: 'Virgin')
    requester = create(:user, responsible_body: local_authority)

    create_list(:extra_mobile_data_request, 1,
                status: :requested,
                mobile_network: virgin,
                created_by_user: requester)
    create_list(:extra_mobile_data_request, 3,
                status: :in_progress,
                mobile_network: ee,
                created_by_user: requester)
    create_list(:extra_mobile_data_request, 5,
                status: :complete,
                mobile_network: three,
                created_by_user: create(:user, responsible_body: local_authority))
    create_list(:extra_mobile_data_request, 1,
                status: :cancelled,
                mobile_network: virgin,
                created_by_user: requester)
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def then_i_see_stats_about_extra_mobile_data_requests
    expect(page).to have_text('10 requests')
    expect(page).to have_text('1 new')
    expect(page).to have_text('3 in progress')
    expect(page).to have_text('1 not valid or cancelled')
    expect(page).to have_text('5 completed')
    expect(page).to have_text('EE 3')
    expect(page).to have_text('Three 5')
    expect(page).to have_text('Virgin 2')
  end

  def then_i_see_stats_about_responsible_body_user_engagement
    expect(page).to have_text('2 responsible body users have signed in')
    expect(page).to have_text('1 responsible body')
  end
end
