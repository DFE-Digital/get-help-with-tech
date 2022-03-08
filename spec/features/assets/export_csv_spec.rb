require 'rails_helper'

RSpec.feature 'Export CSV' do
  context 'request time download' do
    let(:user) { create(:trust_user) }
    let!(:asset) { create(:asset, department_sold_to_id: user.responsible_body.computacenter_reference) }

    scenario 'CSV generated and downloaded' do
      sign_in_as user
      visit assets_path
      click_on 'Export to CSV'

      csv = CSV.parse(page.body, headers: true)
      expect(csv.headers).to match_array(['Serial/IMEI', 'Model', 'Local Authority/Academy Trust', 'School/College', 'BIOS Password', 'Admin Password', 'Hardware Hash'])
      expect(csv[0]['Serial/IMEI']).to eq(asset.serial_number)
      expect(csv[0]['Model']).to eq(asset.model)
      expect(csv[0]['Local Authority/Academy Trust']).to eq(asset.department)
      expect(csv[0]['School/College']).to eq(asset.location)
      expect(csv[0]['BIOS Password']).to eq(asset.bios_password)
      expect(csv[0]['Admin Password']).to eq(asset.admin_password)
      expect(csv[0]['Hardware Hash']).to eq(asset.hardware_hash)
    end
  end

  context 'async email csv' do
    let(:user) { create(:trust_user) }
    let!(:assets) { create_list(:asset, 51, department_sold_to_id: user.responsible_body.computacenter_reference) }
    let!(:other_assets) { create_list(:asset, 10, department_sold_to_id: '8123456789') }

    scenario 'generate CSV in backgroud job, email with a download link' do
      sign_in_as user
      visit assets_path
      expect(Download.count).to be(0)

      click_on 'Export to CSV'
      expect(page).to have_content('You’ll shortly receive an email when your export is ready to download.')
      expect(Download.count).to be(1)

      d = Download.first

      # EMAIL
      email = ActionMailer::Base.deliveries.last
      expect(email.to_addrs).to include(user.email_address)
      expect(email.header['template-id'].value).to eq(Settings.govuk_notify.templates.devices.asset_download_ready)
      expect(email.header[:personalisation].unparsed_value[:link_to_download]).to eq(assets_download_url(uuid: d.uuid, **Rails.configuration.action_mailer.default_url_options))

      # DOWNLOAD PAGE
      visit assets_download_path(uuid: d.uuid)
      expect(page).to have_content('Download your file')

      click_on 'Download this file to your device'
      csv = CSV.parse(page.body, headers: true)
      expect(csv.headers).to match_array(['Serial/IMEI', 'Model', 'Local Authority/Academy Trust', 'School/College', 'BIOS Password', 'Admin Password', 'Hardware Hash'])

      csv.each do |row|
        asset = assets.find { |a| a.serial_number == row['Serial/IMEI'] }

        expect(row['Serial/IMEI']).to eq(asset.serial_number)
        expect(row['Model']).to eq(asset.model)
        expect(row['Local Authority/Academy Trust']).to eq(asset.department)
        expect(row['School/College']).to eq(asset.location)
        expect(row['BIOS Password']).to eq(asset.bios_password)
        expect(row['Admin Password']).to eq(asset.admin_password)
        expect(row['Hardware Hash']).to eq(asset.hardware_hash)

        expect(asset.reload.first_viewed_at).to be_present
      end

      other_assets.each do |asset|
        expect(asset.reload.first_viewed_at).not_to be_present
      end
    end
  end
end
