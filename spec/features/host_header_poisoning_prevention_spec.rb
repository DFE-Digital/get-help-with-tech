require 'rails_helper'

describe 'Host Header Poisoning Prevention', type: :feature do
  context 'when Host header matches Settings.hostname_for_urls' do
    before do
      page.driver.header('Host', 'localhost:3000')
    end

    it 'redirects to the host' do
      visit responsible_body_home_path
      expect(page.current_url).to include(Settings.hostname_for_urls)
    end
  end

  context 'when the Host header does not match Settings.hostname_for_urls' do
    before do
      page.driver.header('Host', 'malicious.example.com')
    end

    it 'does not redirect to the malicious host' do
      visit responsible_body_home_path
      expect(page.current_url).not_to include('malicious.example.com')
    end
  end

  context 'when X-Forwarded-Host header matches Settings.hostname_for_urls' do
    before do
      page.driver.header('X-Forwarded-Host', 'localhost:3000')
    end

    it 'redirects to the host' do
      visit responsible_body_home_path
      expect(page.current_url).to include(Settings.hostname_for_urls)
    end
  end

  context 'when the X-Forwarded-Host header does not match Settings.hostname_for_urls' do
    before do
      page.driver.header('X-Forwarded-Host', 'malicious.example.com')
    end

    it 'does not redirect to the malicious host' do
      visit responsible_body_home_path
      expect(page.current_url).not_to include('malicious.example.com')
    end
  end
end
