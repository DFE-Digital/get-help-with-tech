require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'ISS or Social Care LAs managing multiple Chromebook domains' do
  let(:user) { create(:computacenter_user) }

  context 'signed in as a Computacenter user' do
    let(:user) { create(:computacenter_user) }
    let!(:school) { create(:iss_provision, :with_preorder_information) }
    let!(:school_iss) { create(:iss_provision, :with_preorder_information_chromebooks) }
    let!(:school_scl) { create(:scl_provision, :with_preorder_information_chromebooks) }

    before do
      sign_in_as user
    end

    it 'shows me a ISS or Social Care LAs managing multiple Chromebook domains link' do
      expect(page).to have_link('ISS or Social Care LAs managing multiple Chromebook domains')
    end

    scenario 'navigate to manage iss scl chromebooks page' do
      when_i_visit_manage_iss_scl_chromebooks_page
      then_i_see_the_list_of_all_iss_scl_responsible_bodies_with_possible_multiple_domains
      and_i_see_csv_download_link
    end

    scenario 'download csv' do
      when_i_visit_manage_iss_scl_chromebooks_page
      and_i_click_the_download_csv_link
      then_it_downloads_the_list_as_a_csv_file
    end

    def when_i_visit_manage_iss_scl_chromebooks_page
      visit computacenter_multi_domain_chromebooks_iss_scl_path
    end

    def then_i_see_the_list_of_all_iss_scl_responsible_bodies_with_possible_multiple_domains
      has_scl_iss_schools
      not_have_non_lafunded_schools
    end

    def and_i_see_csv_download_link
      expect(page).to have_text('Download as a CSV file')
    end

    def and_i_click_the_download_csv_link
      click_on 'Download as a CSV file'
    end

    def then_it_downloads_the_list_as_a_csv_file
      expect_download(content_type: 'text/csv')

      has_scl_iss_schools
      not_have_non_lafunded_schools
    end

    def has_scl_iss_schools
      [school_iss, school_scl].each do |s|
        expect(page).to have_text(s.responsible_body.humanized_type)
        expect(page).to have_text(s.responsible_body.computacenter_name)
        expect(page).to have_text(s.responsible_body.computacenter_identifier)
        expect(page).to have_text(s.urn)
        expect(page).to have_text(s.responsible_body.computacenter_reference)
      end
    end

    def not_have_non_lafunded_schools
      expect(page).not_to have_text(school.responsible_body.computacenter_name)
      expect(page).not_to have_text(school.responsible_body.computacenter_identifier)
      expect(page).not_to have_text(school.urn)
      expect(page).not_to have_text(school.responsible_body.computacenter_reference)
    end
  end
end
