require 'rails_helper'

RSpec.feature 'Display asset properties' do
  let(:user) { create(:support_user, :third_line) }
  let(:asset) { create(:asset) }
  let(:bios_unlockable_asset) { create(:asset, :unlockable) }
  let(:asset_page) { PageObjects::Assets::ShowPage.new }
  let(:asset_attr_labels) do
    [
      'Asset tag',
      'Serial/IMEI',
      'BIOS password',
      'Admin password',
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

    expect_asset_properties_to_be_displayed(bios_unlockable_asset, download_unlocker: true)
  end

private

  def expect_asset_properties_to_be_displayed(asset, download_unlocker: false)
    expect(asset_page).to be_displayed(id: asset.id)
    expect(asset_page).to have_home_breadcrumb(text: 'Home')
    expect(asset_page).to have_assets_breadcrumb(text: 'View your device details')
    expect(asset_page).to have_title_header(text: 'Device BIOS/admin password and hardware hash')
    expect(asset_page.attr_labels.map(&:text)).to eq(asset_attr_labels)
    expect_attr_values_to_be_displayed(asset, download_unlocker: download_unlocker)
  end

  def expect_attr_values_to_be_displayed(asset, download_unlocker: false)
    bios = download_unlocker ? 'Download BIOS unlocker' : asset.bios_password
    expect_attr_values_with_bios(asset, bios)

    if download_unlocker
      expect(asset_page.download_unlocker(text: bios)['href']).to eq(bios_unlocker_asset_path(asset))
    else
      expect(asset_page).to have_no_download_unlocker
    end
  end

  def expect_attr_values_with_bios(asset, bios)
    expect(asset_page.attr_values.map(&:text)).to eq([
      asset.tag,
      asset.serial_number,
      bios,
      asset.admin_password,
      asset.hardware_hash,
    ])
  end
end
