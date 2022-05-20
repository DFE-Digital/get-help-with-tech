require 'rails_helper'

RSpec.feature 'List assets' do
  let(:user) { create(:trust_user) }
  let!(:asset) { create(:asset, setting: user.responsible_body) }

  scenario 'non logged-in users required sign in' do
    visit assets_path

    expect(page).to have_content('Sign in')
  end

  scenario 'logged-in users can see a list of their assets' do
    sign_in_as user
    visit assets_path

    expect(page).to have_content(asset.serial_number)
  end
end
