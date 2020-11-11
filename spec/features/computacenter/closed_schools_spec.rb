require 'rails_helper'

RSpec.feature 'Viewing closed schools caps' do
  describe 'signed in as a Computacenter user' do
    let(:user) { create(:computacenter_user) }
    let!(:closed_schools) { create_list(:school, 5, :with_preorder_information, :with_std_device_allocation, :with_coms_device_allocation, :in_lockdown) }
    let!(:partially_closed_schools) { create_list(:school, 10, :with_preorder_information, :with_std_device_allocation, :with_coms_device_allocation, :can_order_for_specific_circumstances) }

    before do
      given_i_am_signed_in_as_a_computacenter_user
    end

    scenario 'navigate to school closures page' do
      when_i_visit_the_home_page
      and_i_click_the_school_closures_link
      then_i_see_the_list_of_all_closed_schools
    end

    scenario 'view partially closed schools' do
      when_i_visit_the_school_closures_page
      and_i_click_on_the_partially_closed_tab
      then_i_see_the_list_of_partially_closed_schools
    end

    scenario 'view schools that are fully closed' do
      when_i_visit_the_school_closures_page
      and_i_click_on_the_fully_closed_tab
      then_i_see_the_list_of_fully_closed_schools
    end

    def given_i_am_signed_in_as_a_computacenter_user
      sign_in_as user
    end

    def when_i_visit_the_home_page
      visit computacenter_home_path
      expect(page).to have_text('Home')
    end

    def and_i_click_the_school_closures_link
      click_on 'Schools that can order'
      expect(page).to have_text 'Schools that can order'
    end

    def then_i_see_the_list_of_all_closed_schools
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'All'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'Ordering for specific circumstances'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'Ordering for closures or self-isolating pupils'

      closed_schools.each do |s|
        expect(page).to have_text(s.urn)
      end

      partially_closed_schools.each do |s|
        expect(page).to have_text(s.urn)
      end
    end

    def when_i_visit_the_school_closures_page
      visit computacenter_closed_schools_path
    end

    def and_i_click_on_the_partially_closed_tab
      click_on 'Ordering for specific circumstances'
    end

    def then_i_see_the_list_of_partially_closed_schools
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'All'
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'Ordering for specific circumstances'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'Ordering for closures or self-isolating pupils'

      closed_schools.each do |s|
        expect(page).not_to have_text(s.urn)
      end

      partially_closed_schools.each do |s|
        expect(page).to have_text(s.urn)
      end
    end

    def and_i_click_on_the_fully_closed_tab
      click_on 'Ordering for closures or self-isolating pupils'
    end

    def then_i_see_the_list_of_fully_closed_schools
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'All'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'Ordering for specific circumstances'
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'Ordering for closures or self-isolating pupils'

      closed_schools.each do |s|
        expect(page).to have_text(s.urn)
      end

      partially_closed_schools.each do |s|
        expect(page).not_to have_text(s.urn)
      end
    end
  end
end
