require 'rails_helper'

RSpec.feature 'Requesting devices for specific circumstances' do
  let(:responsible_body) { create(:local_authority, who_will_order_devices: 'responsible_body') }
  let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body) }

  before do
    sign_in_as rb_user
  end

  scenario 'understanding how to request devices for specific circumstances' do
    click_on 'Get laptops and tablets'
    click_on 'Request devices for specific circumstances'

    expect(page).to have_text('Request devices for specific circumstances')
    expect(page).to have_text('which schools and colleges need the devices')
  end

  context 'when the user belongs to both the responsible body and a school' do
    let(:schools) { create_list(:school, 2) }
    let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body, schools: schools) }

    scenario 'understanding how to request devices for specific circumstances' do
      visit responsible_body_home_path

      click_on 'Get laptops and tablets'
      click_on 'Request devices for specific circumstances'

      expect(page).to have_text('Request devices for specific circumstances')
      expect(page).to have_text('which schools and colleges need the devices')
    end
  end
end
