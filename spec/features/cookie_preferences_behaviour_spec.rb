require 'rails_helper'

RSpec.feature 'Cookie preferences', type: :feature do
  describe 'banner behaviour' do
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

  describe 'preferences page' do
    context 'with no cookie existing' do
      before do
        set_cookie('consented-to-cookies', nil)
      end

      describe 'clicking on the Accept cookies button' do
        let(:initial_page) { guide_to_collecting_mobile_information_path }

        before do
          visit initial_page
          click_on 'Accept all cookies'
        end

        it 'redirects back to the initial page' do
          expect(page).to have_current_path(initial_page)
        end

        it 'tells me my preferences have been saved' do
          expect(page).to have_content(I18n.t('cookie_preferences.success'))
        end

        it 'does not show the cookie banner' do
          expect(page).not_to have_content('We use cookies')
          expect(page).not_to have_link('set your cookie preferences', href: cookie_preferences_path)
        end
      end

      describe 'clicking on the set preferences link' do
        let(:initial_page) { '/' }

        before do
          visit initial_page
          click_on 'set your cookie preferences'
        end

        it 'shows the preferences page' do
          expect(page).to have_content('Do you accept Google Analytics cookies?')
        end

        describe 'when I click Save changes without selecting an option' do
          before do
            click_on 'Save changes'
          end

          it 'shows an error ' do
            expect(page).to have_current_path(cookie_preferences_path)
            expect(page).to have_http_status(:unprocessable_entity)
            expect(page).to have_content('Choose whether you consent to analytics cookies')
          end
        end

        describe 'when I select an option and click Save changes' do
          before do
            choose('No, do not track my website usage')
            click_on 'Save changes'
          end

          it 'redirects back to the home page' do
            expect(page).to have_current_path('/')
          end

          it 'tells me my preferences have been saved' do
            expect(page).to have_content(I18n.t('cookie_preferences.success'))
          end

          it 'does not show the cookie banner' do
            expect(page).not_to have_content('We use cookies')
            expect(page).not_to have_link('set your cookie preferences', href: cookie_preferences_path)
          end
        end
      end
    end
  end
end
