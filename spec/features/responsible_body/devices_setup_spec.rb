require 'rails_helper'

RSpec.feature 'Setting up the devices ordering' do
  let(:rb_user) { create(:responsible_body_user) }

  before do
    rb_user.responsible_body.update(in_devices_pilot: true)
    sign_in_as rb_user
  end

  scenario 'clicking on "Get devices" shows the devices home' do
    click_on 'Get devices'
    expect(page).to have_content 'Schools can now order their own devices'
    expect(page).to have_link 'Continue'
  end

end
