require 'rails_helper'

RSpec.feature 'Updating school responsible body' do
  let(:non_support_third_line_user) { create(:support_user) }
  let(:support_third_line_user) { create(:support_user, :third_line) }
  let(:school) { create(:school) }
  let(:school_page) { PageObjects::Support::SchoolDetailsPage.new }

  scenario 'non support third line users cant change a school responsible body' do
    sign_in_as non_support_third_line_user

    visit support_school_path(school.urn)
    expect_no_responsible_body_row
  end

  scenario 'set same responsible body' do
    sign_in_as support_third_line_user

    visit support_school_path(school.urn)
    select_responsible_body(school.responsible_body_name)

    expect_responsible_body_not_changed_banner(school.name)
  end

  scenario 'failed to set a new responsible body' do
    create(:trust, name: 'Lancashire')

    sign_in_as support_third_line_user

    visit support_school_path(school.urn)
    select_responsible_body('Lancashire')

    expect_responsible_body_change_failed_banner(school.name)
  end

  scenario 'successfully set a new responsible body' do
    school = create(:school, :with_preorder_information)
    create(:trust, name: 'Lancashire')

    sign_in_as support_third_line_user

    visit support_school_path(school.urn)
    select_responsible_body('Lancashire')

    expect_responsible_body_changed_banner(school.name)
  end

private

  def expect_no_responsible_body_row
    expect(school_page).to be_displayed
    expect(school_page.school_details['Responsible Body']).to be_blank
  end

  def expect_responsible_body_change_failed_banner(school_name)
    expect_school_page_with_banner(:warning, "#{school_name} could not be associated with Lancashire!")
  end

  def expect_responsible_body_changed_banner(school_name)
    expect_school_page_with_banner(:success, "#{school_name} is now associated with Lancashire")
  end

  def expect_responsible_body_not_changed_banner(school_name)
    expect_school_page_with_banner(:info, "Responsible body not changed for #{school_name}")
  end

  def expect_school_page_with_banner(type, text)
    expect(school_page).to be_displayed
    expect(page).to have_selector(".app-banner--#{type}", text: text)
  end

  def select_responsible_body(name)
    school_page.school_details['Responsible Body'].follow_action_link
    select(name, from: 'support-school-change-responsible-body-form-responsible-body-id-field')
    click_on('Update')
  end
end
