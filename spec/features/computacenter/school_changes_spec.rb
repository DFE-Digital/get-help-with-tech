require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'Administering school changes' do
  describe 'signed in as a Computacenter user' do
    let(:user) { create(:computacenter_user) }
    let!(:new_schools) { create_list(:school, 2, :with_preorder_information, laptops: [1, 0, 0], routers: [1, 0, 0]) }
    let!(:amended_schools) { create_list(:school, 2, :with_preorder_information, laptops: [1, 0, 0], routers: [1, 0, 0]) }
    let!(:schools) { create_list(:school, 2, :with_preorder_information, laptops: [1, 0, 0], routers: [1, 0, 0]) }

    before do
      given_the_schools_have_the_correct_computacenter_change_states
      given_i_am_signed_in_as_a_computacenter_user
    end

    scenario 'navigate to school changes page' do
      when_i_visit_the_home_page
      and_i_click_the_changes_to_schools_link
      then_i_see_the_list_of_all_changed_schools
    end

    scenario 'view new schools' do
      when_i_visit_the_changes_to_schools_page
      and_i_click_on_the_new_schools_tab
      then_i_see_the_list_of_new_schools
    end

    scenario 'view amended schools' do
      when_i_visit_the_changes_to_schools_page
      and_i_click_on_the_amended_schools_tab
      then_i_see_the_list_of_amended_schools
    end

    scenario 'download csv file of changes' do
      when_i_visit_the_changes_to_schools_page
      and_i_click_the_download_changes_csv_link
      then_it_downloads_the_changed_schools_as_a_csv_file
    end

    scenario 'download csv file of schools and bodies' do
      when_i_visit_the_changes_to_schools_page
      and_i_click_the_download_schools_and_bodies_csv_link
      then_it_downloads_the_schools_and_bodies_as_a_csv_file
    end

    scenario 'update a Ship To reference' do
      when_i_visit_the_changes_to_schools_page
      then_i_see_the_list_of_all_changed_schools
      when_i_click_the_verify_link_for_a_school
      then_i_see_the_verify_ship_to_form
      when_i_update_the_ship_to_reference
      and_i_click_confirm
      then_i_see_an_updated_list_of_all_changed_schools
    end

    scenario 'update a Ship To reference with bad data' do
      when_i_visit_the_changes_to_schools_page
      then_i_see_the_list_of_all_changed_schools
      when_i_click_the_verify_link_for_a_school
      then_i_see_the_verify_ship_to_form
      when_i_update_the_ship_to_reference_with_bad_data
      and_i_click_confirm
      then_i_see_an_error_message
    end

    def given_i_am_signed_in_as_a_computacenter_user
      stub_computacenter_outgoing_api_calls
      sign_in_as user
    end

    def given_the_schools_have_the_correct_computacenter_change_states
      new_schools.each { |s| s.update!(computacenter_change: 'new', computacenter_reference: nil) }
      amended_schools.each(&:computacenter_change_amended!)
      schools.each(&:computacenter_change_none!)
    end

    def when_i_visit_the_home_page
      visit computacenter_home_path
      expect(page).to have_text('Home')
    end

    def and_i_click_the_changes_to_schools_link
      click_on 'Changes to schools (4)'
      expect(page).to have_text 'Changes to schools'
    end

    def then_i_see_the_list_of_all_changed_schools
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'All changes'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'New schools'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'Amended schools'

      new_schools.each do |s|
        expect(page).to have_text("#{s.urn} #{s.name}")
      end

      amended_schools.each do |s|
        expect(page).to have_text("#{s.urn} #{s.name}")
      end

      schools.each do |s|
        expect(page).not_to have_text("#{s.urn} #{s.name}")
      end
    end

    def when_i_visit_the_changes_to_schools_page
      visit computacenter_school_changes_path
    end

    def and_i_click_on_the_new_schools_tab
      click_on 'New schools'
    end

    def then_i_see_the_list_of_new_schools
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'All changes'
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'New schools'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'Amended schools'

      new_schools.each do |s|
        expect(page).to have_text("#{s.urn} #{s.name}")
      end

      amended_schools.each do |s|
        expect(page).not_to have_text("#{s.urn} #{s.name}")
      end

      schools.each do |s|
        expect(page).not_to have_text("#{s.urn} #{s.name}")
      end
    end

    def and_i_click_on_the_amended_schools_tab
      click_on 'Amended schools'
    end

    def then_i_see_the_list_of_amended_schools
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'All changes'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'New schools'
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'Amended schools'

      new_schools.each do |s|
        expect(page).not_to have_text("#{s.urn} #{s.name}")
      end

      amended_schools.each do |s|
        expect(page).to have_text("#{s.urn} #{s.name}")
      end

      schools.each do |s|
        expect(page).not_to have_text("#{s.urn} #{s.name}")
      end
    end

    def and_i_click_the_download_changes_csv_link
      click_on 'Download changes as a CSV file'
    end

    def then_it_downloads_the_changed_schools_as_a_csv_file
      expect_download(content_type: 'text/csv')

      new_schools.each do |s|
        expect(page.body).to have_text(s.urn)
      end

      amended_schools.each do |s|
        expect(page.body).to have_text(s.urn)
      end

      schools.each do |s|
        expect(page).not_to have_text(s.urn)
      end
    end

    def and_i_click_the_download_schools_and_bodies_csv_link
      click_on 'Download all schools and bodies as a CSV file'
    end

    def then_it_downloads_the_schools_and_bodies_as_a_csv_file
      expect_download(content_type: 'text/csv')

      schools.each do |s|
        expect(page.body).to have_text(s.ship_to)
      end
    end

    def when_i_click_the_verify_link_for_a_school
      click_on "Verify ship to reference for #{new_schools.first.name}"
    end

    def then_i_see_the_verify_ship_to_form
      expect(page).to have_text('Verify the school details')
      expect(page).to have_field('Ship To')
    end

    def when_i_update_the_ship_to_reference
      fill_in 'Ship To', with: '80129999'
    end

    def and_i_click_confirm
      click_on 'Confirm'
    end

    def then_i_see_an_updated_list_of_all_changed_schools
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'All changes'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'New schools'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'Amended schools'

      new_schools.each_with_index do |s, i|
        school_name = "#{s.urn} #{s.name}"
        if i == 0
          expect(page).not_to have_text(school_name)
        else
          expect(page).to have_text(school_name)
        end
      end

      amended_schools.each do |s|
        expect(page).to have_text("#{s.urn} #{s.name}")
      end

      schools.each do |s|
        expect(page).not_to have_text("#{s.urn} #{s.name}")
      end
    end

    def when_i_update_the_ship_to_reference_with_bad_data
      fill_in 'Ship To', with: 'Banana'
    end

    def then_i_see_an_error_message
      expect(page).to have_text('Ship To must be a number')
    end
  end
end
