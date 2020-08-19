require 'rails_helper'

RSpec.feature 'Setting up the devices ordering' do
  let(:rb_user) { create(:local_authority_user) }

  before do
    rb_user.responsible_body.update(in_devices_pilot: true)
    sign_in_as rb_user
  end

  scenario 'clicking on "Get devices" shows the devices home' do
    click_on 'Get devices'
    expect(page).to have_content 'Schools can now order their own devices'
    expect(page).to have_link 'Continue'
  end

  scenario 'clicking "Continue" asks me who will order the devices' do
    click_on 'Get devices'
    click_on 'Continue'
    expect(page).to have_content 'Who will order a school’s laptops and tablets?'
    expect(page).to have_field 'Most schools will manage their own orders (recommended)'
  end

  scenario 'submitting the form without choosing an option shows an error' do
    visit responsible_body_devices_who_will_order_edit_path
    click_on 'Continue'
    expect(page).to have_http_status(:unprocessable_entity)
    expect(page).to have_content('There is a problem')
  end

  scenario 'submitting the form after choosing an option shows guidance about that option' do
    visit responsible_body_devices_who_will_order_edit_path
    choose 'Most schools will manage their own orders (recommended)'
    click_on 'Continue'
    expect(page).to have_http_status(:ok)
    expect(page).to have_content('We’ve set each school as managing their own orders')

    visit responsible_body_devices_who_will_order_edit_path
    choose 'Most orders will be managed centrally'
    click_on 'Continue'
    expect(page).to have_http_status(:ok)
    expect(page).to have_content('We’ve set each school as having their orders managed centrally')
  end
end
