require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'Administering responsible body changes' do
  describe 'signed in as a Computacenter user' do
    let(:user) { create(:computacenter_user) }
    let!(:new_trusts) { create_list(:trust, 2, :with_schools) }
    let!(:amended_trusts) { create_list(:trust, 2, :with_schools) }
    let!(:trusts) { create_list(:trust, 2, :with_schools) }

    before do
      given_the_responsible_bodies_have_the_correct_computacenter_change_states
      given_i_am_signed_in_as_a_computacenter_user
    end

    scenario 'navigate to responsible body changes page' do
      when_i_visit_the_home_page
      and_i_click_the_changes_to_responsible_bodies_link
      then_i_see_the_list_of_all_changed_responsible_bodies
    end

    scenario 'view new responsible bodies' do
      when_i_visit_the_changes_to_responsible_bodies_page
      and_i_click_on_the_new_responsible_bodies_tab
      then_i_see_the_list_of_new_responsible_bodies
    end

    scenario 'view amended responsible_bodies' do
      when_i_visit_the_changes_to_responsible_bodies_page
      and_i_click_on_the_amended_responsible_bodies_tab
      then_i_see_the_list_of_amended_responsible_bodies
    end

    scenario 'download csv file' do
      when_i_visit_the_changes_to_responsible_bodies_page
      and_i_click_the_download_csv_link
      then_it_downloads_the_changed_responsible_bodies_as_a_csv_file
    end

    scenario 'update a Sold To reference' do
      when_i_visit_the_changes_to_responsible_bodies_page
      then_i_see_the_list_of_all_changed_responsible_bodies
      when_i_click_the_verify_link_for_a_responsible_body
      then_i_see_the_verify_sold_to_form
      when_i_update_the_sold_to_reference
      and_i_click_confirm
      then_i_see_an_updated_list_of_all_changed_responsible_bodies
    end

    scenario 'update a Sold To reference with bad data' do
      when_i_visit_the_changes_to_responsible_bodies_page
      then_i_see_the_list_of_all_changed_responsible_bodies
      when_i_click_the_verify_link_for_a_responsible_body
      then_i_see_the_verify_sold_to_form
      when_i_update_the_sold_to_reference_with_bad_data
      and_i_click_confirm
      then_i_see_an_error_message
    end

    def given_i_am_signed_in_as_a_computacenter_user
      stub_computacenter_outgoing_api_calls
      sign_in_as user
    end

    def given_the_responsible_bodies_have_the_correct_computacenter_change_states
      new_trusts.each { |s| s.update!(computacenter_change: 'new', computacenter_reference: nil) }
      amended_trusts.each(&:computacenter_change_amended!)
      trusts.each(&:computacenter_change_none!)
    end

    def when_i_visit_the_home_page
      visit computacenter_home_path
      expect(page).to have_text('Home')
    end

    def and_i_click_the_changes_to_responsible_bodies_link
      click_on 'Changes to responsible bodies (4)'
      expect(page).to have_text 'Changes to responsible bodies'
    end

    def then_i_see_the_list_of_all_changed_responsible_bodies
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'All changes'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'New responsible bodies'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'Amended responsible bodies'

      new_trusts.each do |t|
        expect(page).to have_text(t.computacenter_identifier)
      end

      amended_trusts.each do |t|
        expect(page).to have_text(t.computacenter_identifier)
      end

      trusts.each do |t|
        expect(page).not_to have_text(t.computacenter_identifier)
      end
    end

    def when_i_visit_the_changes_to_responsible_bodies_page
      visit computacenter_responsible_body_changes_path
    end

    def and_i_click_on_the_new_responsible_bodies_tab
      click_on 'New responsible bodies'
    end

    def then_i_see_the_list_of_new_responsible_bodies
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'All changes'
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'New responsible bodies'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'Amended responsible bodies'

      within '#responsible-body-changes' do
        new_trusts.each do |t|
          expect(page).to have_text(t.computacenter_identifier)
        end

        amended_trusts.each do |t|
          expect(page).not_to have_text(t.computacenter_identifier)
        end

        trusts.each do |t|
          expect(page).not_to have_text(t.computacenter_identifier)
        end
      end
    end

    def and_i_click_on_the_amended_responsible_bodies_tab
      click_on 'Amended responsible bodies'
    end

    def then_i_see_the_list_of_amended_responsible_bodies
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'All changes'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'New responsible bodies'
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'Amended responsible bodies'

      within '#responsible-body-changes' do
        new_trusts.each do |t|
          expect(page).not_to have_text(t.computacenter_identifier)
        end

        amended_trusts.each do |t|
          expect(page).to have_text(t.computacenter_identifier)
        end

        trusts.each do |t|
          expect(page).not_to have_text(t.computacenter_identifier)
        end
      end
    end

    def and_i_click_the_download_csv_link
      click_on 'Download changes as a CSV file'
    end

    def then_it_downloads_the_changed_responsible_bodies_as_a_csv_file
      expect_download(content_type: 'text/csv')

      new_trusts.each do |t|
        expect(page.body).to have_text(t.computacenter_identifier)
      end

      amended_trusts.each do |t|
        expect(page.body).to have_text(t.computacenter_identifier)
      end

      trusts.each do |t|
        expect(page.body).not_to have_text(t.computacenter_identifier)
      end
    end

    def when_i_click_the_verify_link_for_a_responsible_body
      click_on "Verify sold to reference for #{new_trusts.first.computacenter_name}"
    end

    def then_i_see_the_verify_sold_to_form
      expect(page).to have_text('Verify the responsible body details')
      expect(page).to have_field('Sold To')
    end

    def when_i_update_the_sold_to_reference
      fill_in 'Sold To', with: '80129999'
    end

    def and_i_click_confirm
      click_on 'Confirm'
    end

    def then_i_see_an_updated_list_of_all_changed_responsible_bodies
      expect(page).to have_selector 'li.govuk-tabs__list-item.govuk-tabs__list-item--selected', text: 'All changes'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'New responsible bodies'
      expect(page).to have_selector 'li.govuk-tabs__list-item', text: 'Amended responsible bodies'

      within '#responsible-body-changes' do
        new_trusts.each_with_index do |t, i|
          if i == 0
            expect(page).not_to have_text(t.computacenter_identifier)
          else
            expect(page).to have_text(t.computacenter_identifier)
          end
        end

        amended_trusts.each do |t|
          expect(page).to have_text(t.computacenter_identifier)
        end

        trusts.each do |t|
          expect(page).not_to have_text(t.computacenter_identifier)
        end
      end
    end

    def when_i_update_the_sold_to_reference_with_bad_data
      fill_in 'Sold To', with: 'Banana'
    end

    def then_i_see_an_error_message
      expect(page).to have_text('Sold To must be a number')
    end
  end
end
