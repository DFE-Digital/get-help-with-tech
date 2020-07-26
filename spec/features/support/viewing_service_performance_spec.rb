require 'rails_helper'

RSpec.feature 'Viewing service performance', type: :feature do
  scenario 'DfE users see service stats about user engagement' do
    given_there_have_been_sign_ins_from_responsible_body_and_mno_users

    when_i_sign_in_as_a_dfe_user

    then_i_see_stats_about_user_engagement
  end

  def given_there_have_been_sign_ins_from_responsible_body_and_mno_users
    create(:mno_user, :signed_in_before)
    create(:local_authority_user, :signed_in_before)
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def then_i_see_stats_about_user_engagement
    expect(page).to have_text('2 users have signed in')
    expect(page).to have_text('1 different responsible bodies')
    expect(page).to have_text('1 different mobile network operators')
  end
end
