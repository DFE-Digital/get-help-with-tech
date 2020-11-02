require 'rails_helper'

RSpec.feature 'Viewing closed schools caps' do
  describe 'signed in as a Computacenter user' do
    let(:user) { create(:computacenter_user) }
    let(:other_user) { create(:computacenter_user) }
    let!(:closed_schools) { create_list(:school, 5, :with_preorder_information, :with_std_device_allocation, :with_coms_device_allocation, :in_lockdown) }
    let!(:partially_closed_schools) { create_list(:school, 10, :with_preorder_information, :with_std_device_allocation, :with_coms_device_allocation, :with_shielding_pupils) }

    before do
      given_i_am_signed_in_as_a_computacenter_user
    end

    scenario 'navigate to closed schools page' do
      when_i_visit_the_home_page
      and_i_click_the_closed_schools_link
      then_i_see_the_list_of_all_closed_schools
    end

    scenario 'view schools with specific circumstances' do
      when_i_visit_the_closed_schools_page
      and_i_click_on_the_partially_closed_tile
      then_i_see_the_list_of_partially_closed_schools
    end

    scenario 'view schools that are fully closed' do
      when_i_visit_the_closed_schools_page
      and_i_click_on_the_fully_closed_tile
      then_i_see_the_list_of_fully_closed_schools
    end

    def given_i_am_signed_in_as_a_computacenter_user
      sign_in_as user
    end

    def when_i_visit_the_home_page
      visit computacenter_home_path
      expect(page).to have_text('Home')
    end

    def and_i_click_the_closed_schools_link
      click_on 'Closed schools'
      expect(page).to have_text 'Closed schools'
    end

    def then_i_see_the_list_of_all_closed_schools
      expect(page).to have_text "#{closed_schools.count + partially_closed_schools.count} with restrictions"
      expect(page).to have_text "#{partially_closed_schools.count} partially closed"
      expect(page).to have_text "#{closed_schools.count} fully closed"

      closed_schools.each do |s|
        expect(page).to have_text(s.urn)
      end

      partially_closed_schools.each do |s|
        expect(page).to have_text(s.urn)
      end
    end

    def when_i_visit_the_closed_schools_page
      visit computacenter_closed_schools_path
    end

    def and_i_click_on_the_partially_closed_tile
      click_on "#{partially_closed_schools.count} partially closed"
    end

    def then_i_see_the_list_of_partially_closed_schools
      expect(page).to have_selector 'a.app-card__link', text: "#{closed_schools.count + partially_closed_schools.count} with restrictions"
      expect(page).to have_selector 'a.app-card__link--selected', text: "#{partially_closed_schools.count} partially closed"
      expect(page).to have_selector 'a.app-card__link', text: "#{closed_schools.count} fully closed"

      closed_schools.each do |s|
        expect(page).not_to have_text(s.urn)
      end

      partially_closed_schools.each do |s|
        expect(page).to have_text(s.urn)
      end
    end

    def and_i_click_on_the_fully_closed_tile
      click_on "#{closed_schools.count} fully closed"
    end

    def then_i_see_the_list_of_fully_closed_schools
      expect(page).to have_selector 'a.app-card__link', text: "#{closed_schools.count + partially_closed_schools.count} with restrictions"
      expect(page).to have_selector 'a.app-card__link', text: "#{partially_closed_schools.count} partially closed"
      expect(page).to have_selector 'a.app-card__link--selected', text: "#{closed_schools.count} fully closed"

      closed_schools.each do |s|
        expect(page).to have_text(s.urn)
      end

      partially_closed_schools.each do |s|
        expect(page).not_to have_text(s.urn)
      end
    end
  end
end
