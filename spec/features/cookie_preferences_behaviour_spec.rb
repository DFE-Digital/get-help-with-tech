require 'rails_helper'

RSpec.feature 'Cookie preferences', type: :feature do
  context 'when no preference has been set' do
    before do
      set_cookie('consented-to-cookies', nil)
    end

    it 'shows the cookie banner on visiting the homepage' do
      visit '/'
      expect(page).to have_content('We use cookies')
      expect(page).to have_link('set your cookie preferences', href: cookie_preferences_path)
    end

    it 'does not show the cookie banner on the cookie consent page' do
      visit cookie_preferences_path
      expect(page).not_to have_content('We use cookies')
      expect(page).not_to have_link('set your cookie preferences', href: cookie_preferences_path)
    end
  end
  context 'when a preference has been set to false' do
    before do
      set_cookie('consented-to-cookies', false)
    end

    it 'does not show the cookie banner on visiting the homepage' do
      visit '/'
      expect(page).not_to have_content('We use cookies')
      expect(page).not_to have_link('set your cookie preferences', href: cookie_preferences_path)
    end
  end

  context 'when a preference has been set to true' do
    before do
      set_cookie('consented-to-cookies', true)
    end

    it 'does not show the cookie banner on visiting the homepage' do
      visit '/'
      expect(page).not_to have_content('We use cookies')
      expect(page).not_to have_link('set your cookie preferences', href: cookie_preferences_path)
    end
  end
end
