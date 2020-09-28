require 'rails_helper'

RSpec.feature 'Change school Chromebook information' do
  let(:school) { create(:school, :la_maintained) }
  let(:school_user) { create(:school_user, full_name: 'AAA Smith', school: school) }

  before do
    create(:preorder_information, school: school_user.school, who_will_order_devices: 'school', will_need_chromebooks: 'yes')
    create(:school_device_allocation, school: school_user.school, device_type: 'std_device', allocation: 63)
  end

  context 'logged in as a school user' do
    before do
      sign_in_as school_user
    end

    context 'when I visit the school details and click on the Chromebook information "Change" link' do
      before do
        allow(Gsuite).to receive(:is_gsuite_domain?).and_return(true)
        click_on 'Check your school details'
        first('a', text: 'Change').click
      end

      it 'allows me to change whether the school will need Chromebooks' do
        expect(page).to have_content('Will your school need to order Chromebooks?')
      end

      it 'lets me choose Yes or No' do
        expect(page).to have_field('Yes, we will order Chromebooks')
        expect(page).to have_field('No, we will not order Chromebooks')
      end

      it 'shows fields for domain and recovery email when I choose Yes' do
        choose('Yes, we will order Chromebooks')
        expect(page).to have_field('School or local authority domain')
        expect(page).to have_field('Recovery email address')
      end

      it 'shows an error when I do not supply valid information' do
        choose('Yes, we will order Chromebooks')
        fill_in('School or local authority domain', with: '')
        click_on 'Save'
        expect(page).to have_http_status(:unprocessable_entity)
        expect(page).to have_content('There is a problem')
      end

      it 'goes back to the school details page when I save valid information' do
        choose('Yes, we will order Chromebooks')
        fill_in('School or local authority domain', with: 'some.domain.org')
        fill_in('Recovery email address', with: 'someone@someotherdomain.org')
        click_on 'Save'
        expect(page).to have_http_status(:ok)
        expect(page).to have_content('Check your school details')
        expect(page).to have_content('some.domain.org')
        expect(page).to have_content('someone@someotherdomain.org')
      end
    end
  end
end
