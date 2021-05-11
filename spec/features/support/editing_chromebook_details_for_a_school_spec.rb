require 'rails_helper'

RSpec.describe 'Editing a school’s Chromebook details from the support area' do
  let(:school_details_page) { PageObjects::Support::SchoolDetailsPage.new }

  before do
    allow(Gsuite).to receive(:is_gsuite_domain?).and_return(true)
    given_i_sign_in_as_a_support_user_with_access_to_the_computacenter_area
  end

  it 'setting Chromebook information' do
    given_a_school_with_preorder_information
    and_the_school_does_not_have_chromebook_information_specified

    when_i_navigate_to_the_school_page_in_support
    and_i_add_chromebook_information

    then_the_chromebook_details_are_updated_in_the_support_console
    and_the_chromebook_details_are_updated_in_the_computacenter_chromebook_details_feed
  end

  it 'removing Chromebook information' do
    given_a_school_with_preorder_information
    and_the_school_has_chromebook_information_specified

    when_i_navigate_to_the_school_page_in_support
    and_i_remove_chromebook_information

    then_the_chromebook_details_are_not_present_in_the_support_console
    and_the_chromebook_details_are_not_present_in_the_computacenter_chromebook_details_feed
  end

  def given_a_school_with_preorder_information
    @school = create(:school, :la_maintained, :with_preorder_information)
  end

  def and_the_school_does_not_have_chromebook_information_specified
    @school.preorder_information.update(
      will_need_chromebooks: 'no',
      school_or_rb_domain: nil,
      recovery_email_address: nil,
    )
  end

  def and_the_school_has_chromebook_information_specified
    @school.preorder_information.update(
      will_need_chromebooks: 'yes',
      school_or_rb_domain: 'somedomain.com',
      recovery_email_address: 'someone@someotherdomain.com',
    )
  end

  def given_i_sign_in_as_a_support_user_with_access_to_the_computacenter_area
    sign_in_as create(:support_user, is_computacenter: true)
  end

  def when_i_navigate_to_the_school_page_in_support
    visit support_school_path(@school.urn)
    expect(school_details_page).to be_displayed
  end

  def and_i_add_chromebook_information
    school_details_page
      .school_details['Ordering Chromebooks?']
      .follow_action_link

    choose 'Yes, we’ll order Chromebooks'
    fill_in 'School or local authority', with: 'somedomain.com'
    fill_in 'Recovery email address', with: 'someone@someotherdomain.com'
    click_on 'Save'
  end

  def and_i_remove_chromebook_information
    school_details_page
      .school_details['Ordering Chromebooks?']
      .follow_action_link

    choose 'No, we will not order Chromebooks'
    click_on 'Save'
  end

  def then_the_chromebook_details_are_updated_in_the_support_console
    expect(school_details_page.school_details['Ordering Chromebooks?'].value).to eq('Yes, we’ll order Chromebooks')
    expect(school_details_page.school_details['Domain'].value).to eq('somedomain.com')
    expect(school_details_page.school_details['Recovery email'].value).to eq('someone@someotherdomain.com')
  end

  def then_the_chromebook_details_are_not_present_in_the_support_console
    expect(school_details_page.school_details['Ordering Chromebooks?'].value).to eq('No, we will not order Chromebooks')
    expect(school_details_page.school_details['Domain']).to be_nil
    expect(school_details_page.school_details['Recovery email']).to be_nil
  end

  def and_the_chromebook_details_are_updated_in_the_computacenter_chromebook_details_feed
    visit computacenter_home_path
    click_on 'Download Chromebook details'
    expect(page.body).to include([@school.urn, 'somedomain.com', 'someone@someotherdomain.com'].join(','))
  end

  def and_the_chromebook_details_are_not_present_in_the_computacenter_chromebook_details_feed
    visit computacenter_home_path
    click_on 'Download Chromebook details'
    expect(page.body).not_to include(@school.urn.to_s)
  end
end
