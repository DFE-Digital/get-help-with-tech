require 'rails_helper'

RSpec.feature 'Exporting users' do
  let(:computacenter_user) { create(:computacenter_user) }
  let(:csv) { CSV.parse(page.body, headers: true) }
  let(:expected_headers) { Support::UserReport.headers }
  let(:relevant_users_count) { User.count }
  let(:school_and_rb_users_count) { User.from_responsible_body_or_schools.count }
  let(:search_page) { PageObjects::Support::Users::SearchPage.new }
  let(:support_user) { create(:support_user) }

  scenario 'support user can export' do
    given_i_am_signed_in_as_a_support_user
    and_there_are_school_responsible_body_support_and_supplier_users

    when_i_visit_the_user_search_page
    and_i_click_the_export_button
    then_the_csv_should_contain_the_school_and_rb_users
  end

  scenario 'support user can export audit data' do
    given_i_am_signed_in_as_a_support_user
    and_there_are_school_responsible_body_support_and_supplier_users

    when_i_visit_the_user_search_page
    and_i_click_the_export_audit_data_checkbox
    and_i_click_the_export_button
    then_the_csv_should_contain_all_users
  end

  scenario 'Computacenter user can not export' do
    given_i_am_signed_in_as_a_computacenter_user
    and_there_are_school_responsible_body_support_and_supplier_users

    when_i_visit_the_user_search_page
    then_i_do_not_see_the_export_button
  end

  def and_i_click_the_export_audit_data_checkbox
    search_page.audit_data_checkbox.click
  end

  def and_i_click_the_export_button
    search_page.export_button.click
  end

  def and_there_are_school_responsible_body_support_and_supplier_users
    create_list(:school_user, 2)
    create_list(:local_authority_user, 2)
    create_list(:computacenter_user, 2)
    create_list(:support_user, 2)
  end

  def given_i_am_signed_in_as_a_support_user
    sign_in_as support_user
  end

  def given_i_am_signed_in_as_a_computacenter_user
    sign_in_as computacenter_user
  end

  def then_i_do_not_see_the_export_button
    expect(search_page).not_to have_export_button
  end

  def then_the_csv_should_contain_all_users
    expect(csv.headers).to match_array(expected_headers)
    expect(csv.size).to eq(relevant_users_count)
  end

  def then_the_csv_should_contain_the_school_and_rb_users
    expect(csv.headers).to match_array(expected_headers)
    expect(csv.size).to eq(school_and_rb_users_count)
  end

  def when_i_visit_the_user_search_page
    search_page.load
  end
end
