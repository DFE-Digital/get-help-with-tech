require 'rails_helper'

RSpec.feature 'Change school Chromebook information', skip: 'Disabled for 30 Jun 2021 service closure' do
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
        visit details_school_path(school)
        first('a', text: 'Change').click
      end

      it 'allows me to change whether the school will need Chromebooks' do
        expect(page).to have_content('Will you need to order Chromebooks?')
      end

      it 'lets me choose Yes or No' do
        expect(page).to have_field('Yes, we’ll order Chromebooks')
        expect(page).to have_field('No, we will not order Chromebooks')
      end

      context 'when I choose Yes' do
        before do
          choose('Yes, we’ll order Chromebooks')
        end

        it 'shows a recovery email field' do
          expect(page).to have_field('Recovery email address')
        end

        context 'and the school is a Further Education School' do
          let(:school) { create(:fe_school) }

          it 'shows the correct label for domain' do
            expect(page).to have_field("#{school.institution_type.capitalize} email domain registered for G Suite for Education")
          end
        end

        context 'when the school is not a Further Education School' do
          it 'shows the correct label for domain' do
            expect(page).to have_field('School or local authority email domain registered for G Suite for Education')
          end
        end
      end

      it 'shows an error when I do not supply valid information' do
        choose('Yes, we’ll order Chromebooks')
        fill_in('School or local authority email domain registered for G Suite for Education', with: '')
        click_on 'Save'
        expect(page).to have_http_status(:unprocessable_entity)
        expect(page).to have_content('There is a problem')
        expect(page).to have_content('Enter an email domain registered for G Suite for Education')
      end

      it 'goes back to the school details page when I save valid information' do
        choose('Yes, we’ll order Chromebooks')
        fill_in('School or local authority email domain registered for G Suite for Education', with: 'some.domain.org')
        fill_in('Recovery email address', with: 'someone@someotherdomain.org')
        click_on 'Save'
        expect(page).to have_http_status(:ok)
        expect(page).to have_content('Check your organisation’s details')
        expect(page).to have_content('some.domain.org')
        expect(page).to have_content('someone@someotherdomain.org')
      end
    end
  end
end
