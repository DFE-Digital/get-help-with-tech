require 'rails_helper'

RSpec.feature 'Viewing service performance', type: :feature do
  let(:local_authority) { create(:local_authority) }

  scenario 'DfE users see service stats about user engagement' do
    given_there_have_been_sign_ins_from_responsible_body_and_mno_users
    and_some_bt_wifi_vouchers_have_been_downloaded

    when_i_sign_in_as_a_dfe_user

    then_i_see_stats_about_user_engagement
    and_i_see_stats_about_bt_wifi_vouchers
  end

  def given_there_have_been_sign_ins_from_responsible_body_and_mno_users
    create(:mno_user, :signed_in_before)
    create(:local_authority_user, :signed_in_before, responsible_body: local_authority)
  end

  def and_some_bt_wifi_vouchers_have_been_downloaded
    create_list(:bt_wifi_voucher, 12, responsible_body: local_authority, distributed_at: 3.days.ago)
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def then_i_see_stats_about_user_engagement
    expect(page).to have_text('2 users have signed in')
    expect(page).to have_text('1 different responsible bodies')
    expect(page).to have_text('1 different mobile network operators')
  end

  def and_i_see_stats_about_bt_wifi_vouchers
    expect(page).to have_text('12 vouchers downloaded by 1 responsible bodies')
  end
end
