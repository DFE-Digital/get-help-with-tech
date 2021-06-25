require 'rails_helper'

RSpec.feature 'Huawei router password', type: :feature do
  let(:school_with_router_allocation) { create(:school, :with_coms_device_allocation) }
  let(:iss_provision) { create(:iss_provision, :with_coms_device_allocation) }
  let(:user_for_organisation_without_router_allocation) { create(:school_user) }
  let(:user) { create(:school_user, school: school_with_router_allocation) }
  let(:trust) { create(:trust, :multi_academy_trust, :vcap_feature_flag) }
  let(:school) { create(:school, :with_coms_device_allocation, responsible_body: trust) }
  let(:rb_user) { create(:local_authority_user, responsible_body: trust) }
  let(:la_user) { create(:la_funded_place_user, school: iss_provision) }

  scenario 'logged out' do
    visit root_path
    click_on 'Internet access'
    click_on 'How to reset'
    click_on 'Sign in to see your Huawei'
    expect_login_screen
  end

  scenario 'logged in but no router allocation' do
    sign_in_as user_for_organisation_without_router_allocation

    visit internet_school_path(school)
    expect(page).to have_no_link('See your Huawei router password')
  end

  scenario 'school user' do
    sign_in_as user

    go_to_huawei_password
    expect_password_and_breadcrumb
  end

  scenario 'responsible body user' do
    create(:preorder_information, :rb_will_order, school: school)

    trust.add_school_to_virtual_cap_pools!(school)

    sign_in_as rb_user

    go_to_huawei_password
    expect_password_and_breadcrumb
  end

  scenario 'la-funded user' do
    sign_in_as la_user

    go_to_huawei_password
    expect_password_and_breadcrumb
  end

private

  def go_to_huawei_password
    visit internet_school_path(school)
    visit huawei_router_password_path
  end

  def expect_password_and_breadcrumb
    expect(page).to have_text 'Password:'
    expect(page).to have_link('Request internet access')
  end

  def expect_login_screen
    expect(page).to have_text 'Enter your email address'
  end
end
