require 'rails_helper'

RSpec.feature 'Managing contacts', type: :feature do
  let(:school_page) { PageObjects::Support::Devices::SchoolDetailsPage.new }
  let(:contact_page) { PageObjects::Support::Devices::ContactPage.new }

  let(:school) { create(:school, :with_headteacher_contact) }
  let(:contact) { school.contacts.first }

  scenario 'support user updates contact' do
    given_a_school_with_a_contact
    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_school_page
    then_i_see_the_school_contacts

    when_i_change_contact_info
    then_i_see_updated_contact_info
  end

  def given_a_school_with_a_contact
    school
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def and_i_visit_the_school_page
    school_page.load(urn: school.urn)
  end

  def then_i_see_the_school_contacts
    expect(school_page.contacts).to have_content(contact.full_name)
  end

  def when_i_change_contact_info
    school_page.contacts.click_link 'Change'
    contact_page.full_name.fill_in with: 'Other Name'
    contact_page.submit.click
  end

  def then_i_see_updated_contact_info
    expect(school_page).to have_content('School contact has been updated')
    expect(school_page.contacts).to have_content('Other Name')
  end
end
