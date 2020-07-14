require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'Downloading BT Wifi vouchers', type: :feature do
  let(:user) { create(:local_authority_user) }
  let(:responsible_body_vouchers_download_page) { PageObjects::ResponsibleBody::VouchersDownloadPage.new }

  before do
    given_i_am_signed_in_as_a_responsible_body_user
  end

  context 'when the MNO offer is disabled' do
    before do
      FeatureFlag.deactivate(:extra_mobile_data_offer)
    end

    scenario 'sends the user a CSV file with their vouchers' do
      given_the_responsible_body_has_some_bt_wifi_vouchers
      and_i_visit_the_responsible_body_homepage
      then_i_am_on_the_download_vouchers_page

      and_i_download_logins
      then_i_get_a_csv_file_with_the_voucher_usernames_and_passwords
    end
  end

  context 'when the MNO offer is enabled' do
    before do
      FeatureFlag.activate(:extra_mobile_data_offer)
    end

    scenario 'sends the user a CSV file with their vouchers' do
      given_the_responsible_body_has_some_bt_wifi_vouchers
      and_i_visit_the_responsible_body_homepage

      when_i_visit_the_download_vouchers_link
      and_i_download_logins
      then_i_get_a_csv_file_with_the_voucher_usernames_and_passwords
    end
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def given_the_responsible_body_has_some_bt_wifi_vouchers
    @bt_wifi_vouchers = create_list(:bt_wifi_voucher, 4, responsible_body: user.responsible_body)
  end

  def and_i_visit_the_responsible_body_homepage
    visit responsible_body_home_path
    expect(page).to have_http_status(:ok)
  end

  def when_i_visit_the_download_vouchers_link
    click_link 'Download your BT hotspot log-ins'
  end

  def and_i_download_logins
    click_link 'Download log-ins'
  end

  def then_i_get_a_csv_file_with_the_voucher_usernames_and_passwords
    expect_download(content_type: 'text/csv')
    expect(page.body).to include('Username,Password')
    @bt_wifi_vouchers.each do |voucher|
      expect(page.body).to include("#{voucher.username},#{voucher.password}")
    end
  end

  def then_i_am_on_the_download_vouchers_page
    expect(responsible_body_vouchers_download_page).to be_displayed
  end
end
