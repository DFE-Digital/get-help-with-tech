require 'rails_helper'

RSpec.feature 'Updating addresses' do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school) }
  let(:school_page) { PageObjects::Support::SchoolDetailsPage.new }
  let(:address_page) { PageObjects::Support::AddressPage.new }

  before do
    school.update(computacenter_change: 'none')
    sign_in_as support_user
  end

  describe 'visiting a school details page' do
    before do
      visit support_school_path(school.urn)
    end

    it 'shows the address' do
      school.address_components.each do |line|
        expect(school_page).to have_text line
      end
    end

    describe 'clicking Change' do
      before do
        click_on 'Change address'
      end

      it 'shows me a form to update the address' do
        expect(address_page).to be_displayed(urn: school.urn)
        expect(address_page.h1.text).to eql('Update an address')
      end

      it 'shows Computacenter has address in sync' do
        expect(address_page.text).to include('ACTIVE')
      end

      context 'updating the address' do
        before do
          address_page.address_1_field.set 'New address 1'
          address_page.address_2_field.set 'New address 2'
          address_page.address_3_field.set 'New address 3'

          address_page.town_field.set 'New town'
          address_page.county_field.set 'New county'
          address_page.postcode_field.set 'NE1 6EE'

          address_page.submit.click
        end

        it 'takes me back to the school details page' do
          expect(school_page).to be_displayed(urn: school.urn)
          expect(school_page).to have_text('Address has been updated')
        end

        it 'shows the new updated address' do
          expect(school_page).to have_text('New address 1')
          expect(school_page).to have_text('New address 2')
          expect(school_page).to have_text('New address 3')

          expect(school_page).to have_text('New town')
          expect(school_page).to have_text('New county')
          expect(school_page).to have_text('NE1 6EE')
        end

        it 'marks address as pending for CC to update' do
          click_on 'Change address'
          expect(address_page.text).to include('PENDING')
        end
      end
    end
  end
end
