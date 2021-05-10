require 'rails_helper'

RSpec.feature 'Change school Chromebook information', type: :feature do
  let(:school) { create(:school) }
  let(:iss_provision) { create(:iss_provision) }
  let(:user) { create(:school_user) }
  let(:rb_user) { create(:local_authority_user) }
  let(:la_user) { create(:la_funded_place_user, school: iss_provision) }

  scenario 'school user' do
    sign_in_as user

    go_to_huawei_password
    expect_password_and_breadcrumb
  end

  scenario 'responsible body user' do
    sign_in_as rb_user

    go_to_huawei_password
    expect_password_and_breadcrumb
  end

  scenario 'la-funded user' do
    sign_in_as la_user

    go_to_huawei_password
    expect_password_and_breadcrumb
  end

  def go_to_huawei_password
    click_on 'Get internet access'
    click_on 'See your Huawei router password'
  end

  def expect_password_and_breadcrumb
    expect(page).to have_text 'Password:'
    expect(page).to have_link('Get internet access')
  end
end
