require 'rails_helper'

RSpec.describe 'View school details' do
  let(:school_user) { create(:school_user, full_name: 'AAA Smith') }

  before do
    create(:preorder_information, school: school_user.school, who_will_order_devices: 'responsible_body', will_need_chromebooks: 'yes')
    create(:school_device_allocation, school: school_user.school, device_type: 'std_device', allocation: 63)
  end

  context 'logged in as a school user' do
    before do
      sign_in_as school_user
    end

    context 'when I click on "Check your organisation’s details"' do
      before do
        click_on 'Check your organisation’s details'
      end

      it 'shows me my school details' do
        expect(page).to have_content(school_user.school.name)
        expect(page).to have_content('Check your organisation’s details')
        expect(page).to have_content('63 devices')
        expect(page).to have_content("Will you need to order Chromebooks?\nYes")
      end
    end
  end
end
