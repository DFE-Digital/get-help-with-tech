require 'rails_helper'

RSpec.feature 'Display asset properties' do
  let(:user) { create(:support_user, :third_line) }
  let(:asset) { create(:asset) }
  let(:bios_unlockable_asset) { create(:asset, :unlockable) }
  let(:asset_page) { PageObjects::Assets::ShowPage.new }
  let(:asset_detail_labels) do
    [
      'Asset tag',
      'Serial/IMEI',
    ]
  end
  let(:asset_secrets_labels) do
    [
      'BIOS password',
      'Admin password',
    ]
  end
  let(:asset_hardware_labels) do
    [
      'Hardware hash',
    ]
  end

  scenario "non logged-in users can't see the asset properties page" do
    visit asset_path(asset)

    expect(asset_page).not_to be_displayed
  end

  scenario 'logged-in users can see a non-bios-unlockable asset' do
    sign_in_as user

    visit asset_path(asset)

    expect_asset_properties_to_be_displayed(asset)
  end

  scenario 'logged-in users can see a bios-unlockable asset with downloadable unlocker' do
    sign_in_as user

    visit asset_path(bios_unlockable_asset)

    expect_asset_properties_to_be_displayed(bios_unlockable_asset, download_bios_unlocker: true)
  end

  context 'empty values' do
    let(:asset) { create(:asset, :lacks_bios_password, :lacks_admin_password, :lacks_hardware_hash) }

    scenario 'show hyphens' do
      sign_in_as user

      visit asset_path(asset)

      expect_asset_properties_to_be_displayed(asset)
    end
  end

private

  def expect_asset_properties_to_be_displayed(asset, download_bios_unlocker: false)
    expect(asset_page).to have_home_breadcrumb(text: 'Home')
    expect(asset_page).to have_assets_breadcrumb(text: 'View your device details')
    expect(asset_page).to have_title_header(text: 'Device BIOS/admin password and hardware hash')

    # labels for each table
    expect(asset_page.asset_detail_labels.map(&:text)).to eq(asset_detail_labels)
    expect(asset_page.asset_secrets_labels.map(&:text)).to eq(asset_secrets_labels)
    expect(asset_page.asset_hardware_labels.map(&:text)).to eq(asset_hardware_labels)

    # values for each table
    expect(asset_page.asset_detail_values.map(&:text)).to eq([asset.tag, asset.serial_number])
    expect(asset_page.asset_secrets_values.map(&:text)).to eq([
      bios_password_value(asset, download_bios_unlocker) || '-',
      asset.admin_password || '-',
    ])
    expect(asset_page.asset_hardware_values.map(&:text)).to eq([asset.hardware_hash || '-'])

    # download bios unlocker link
    if download_bios_unlocker
      expect(asset_page.download_bios_unlocker_link['href']).to eq(bios_unlocker_asset_path(asset))
    end
  end

  def bios_password_value(asset, download_bios_unlocker)
    download_bios_unlocker ? 'Download BIOS unlocker' : asset.bios_password
  end
end
