require 'rails_helper'

RSpec.feature 'Setting up the devices ordering' do
  let(:responsible_body) { create(:local_authority, who_will_order_devices: 'responsible_body') }
  let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body) }
  let!(:school) { create(:school, :la_maintained, :with_preorder_information, responsible_body: responsible_body) }

  before do
    allow(Gsuite).to receive(:is_gsuite_domain?).and_return(true)
    school.preorder_information.update!(who_will_order_devices: 'responsible_body', status: 'needs_info')
    sign_in_as rb_user
    visit responsible_body_devices_schools_path
  end

  scenario 'when the responsible_body will order devices' do
    when_i_click_on_a_school_that_has_no_chromebook_information
    it_tells_me_the_local_authority_will_order_devices
    and_asks_me_if_the_school_will_need_chromebooks

    when_i_choose_no_they_will_not_need_chromebooks
    and_i_click_save
    it_shows_me_that_they_will_not_need_chromebooks
    and_the_status_has_changed_to_ready
    and_shows_me_a_link_to_change_whether_they_need_chromebooks
    and_it_does_not_show_me_the_domain_and_recovery_email_rows
    when_i_click_on_the_change_link
    and_choose_yes_they_will_need_chromebooks
    it_shows_me_fields_for_domain_and_recovery_email_address
    when_i_click_save_without_providing_both_fields
    it_shows_me_an_error
    when_i_provide_valid_entries_for_both_fields
    it_shows_the_chromebook_information_i_entered
    and_it_shows_me_the_domain_and_recovery_email_rows
    and_the_status_has_changed_to_ready
  end

  def when_i_click_on_a_school_that_has_no_chromebook_information
    click_on school.name
  end

  def it_tells_me_the_local_authority_will_order_devices
    expect(page).to have_content 'The local authority orders devices'
  end

  def and_asks_me_if_the_school_will_need_chromebooks
    expect(page).to have_content 'Will your order include Chromebooks?'
  end

  def when_i_choose_no_they_will_not_need_chromebooks
    choose 'No, we will not order Chromebooks'
  end

  def and_i_click_save
    click_on 'Save'
  end

  def it_shows_me_that_they_will_not_need_chromebooks
    within('.govuk-summary-list') do
      expect(page).to have_content 'No, we will not order Chromebooks'
    end
  end

  def and_it_shows_me_the_domain_and_recovery_email_rows
    within('.govuk-summary-list') do
      expect(page).to have_content 'Domain'
      expect(page).to have_content 'Recovery email'
    end
  end

  def and_it_does_not_show_me_the_domain_and_recovery_email_rows
    within('.govuk-summary-list') do
      expect(page).not_to have_content 'Domain'
      expect(page).not_to have_content 'Recovery email'
    end
  end

  def and_shows_me_a_link_to_change_whether_they_need_chromebooks
    expect(page).to have_link('Change', href: responsible_body_devices_school_chromebooks_edit_path(school_urn: school.urn))
  end

  def when_i_click_on_the_change_link
    first('a', text: 'Change whether Chromebooks are needed').click
  end

  def and_choose_yes_they_will_need_chromebooks
    choose 'Yes, we’ll order Chromebooks'
  end

  def it_shows_me_fields_for_domain_and_recovery_email_address
    expect(page).to have_field('School or local authority email domain registered for G Suite for Education')
    expect(page).to have_field('Recovery email address')
  end

  def when_i_click_save_without_providing_both_fields
    click_on 'Save'
  end

  def it_shows_me_an_error
    expect(page).to have_content('There is a problem')
    expect(page).to have_http_status(:unprocessable_entity)
  end

  def when_i_provide_valid_entries_for_both_fields
    fill_in 'School or local authority email domain registered for G Suite for Education', with: 'somedomain.com'
    fill_in 'Recovery email address', with: 'someone@someotherdomain.com'
    click_on 'Save'
  end

  def it_shows_the_chromebook_information_i_entered
    expect(page).to have_content 'somedomain.com'
    expect(page).to have_content 'someone@someotherdomain.com'
  end

  def and_the_status_has_changed_to_ready
    expect(page).to have_css('.govuk-tag', text: 'Ready')
  end
end
