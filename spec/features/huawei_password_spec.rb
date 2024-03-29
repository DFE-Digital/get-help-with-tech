require 'rails_helper'

RSpec.feature 'Huawei router password', type: :feature do
  let(:school_with_router_allocation) { create(:school, routers: [1, 0, 0]) }
  let(:iss_provision) { create(:iss_provision, routers: [1, 0, 0]) }
  let(:user_for_organisation_without_router_allocation) { create(:school_user) }
  let(:user) { create(:school_user, school: school_with_router_allocation) }
  let(:trust) { create(:trust, :multi_academy_trust, :vcap) }
  let(:school) { create(:school, routers: [1, 0, 0], responsible_body: trust) }
  let(:rb_user) { create(:local_authority_user, responsible_body: trust) }
  let(:la_user) { create(:la_funded_place_user, school: iss_provision) }

  before do
    stub_computacenter_outgoing_api_calls
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
    SchoolSetWhoManagesOrdersService.new(school, :responsible_body).call

    trust.reload

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
    expect(page).to have_link('Your account')
  end

  def expect_login_screen
    expect(page).to have_text 'Enter your email address'
  end
end
