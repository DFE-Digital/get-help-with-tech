require 'rails_helper'

RSpec.describe 'Google Analytics behaviour' do
  let(:consent) { nil }
  let(:tracking_id) { nil }
  let(:google_tag) { /<script [^>]*src="https:\/\/www.googletagmanager.com\/gtag\/js\?id=#{tracking_id}"/ }
  let(:anonymize_ip_config) { /gtag\('config',[^)]+'anonymize_ip': true[^)]*\)/ }

  before do
    allow(Settings.google.analytics).to receive(:tracking_id).and_return(tracking_id)
    set_cookie 'consented-to-cookies', consent
    visit '/'
  end

  context 'when tracking_id is present in Settings.google.analytics' do
    let(:tracking_id) { 'MYTRACKING-ID' }

    context 'and the user has given consent to GA cookies' do
      let(:consent) { 'yes' }

      it 'renders the GA tag code' do
        expect(page.source).to match(google_tag)
      end

      it 'explicitly sets anonymize_ip to true' do
        expect(page.source).to match(anonymize_ip_config)
      end
    end

    context 'and the user has denied consent to GA cookies' do
      let(:consent) { 'no' }

      it 'does not render the GA tag code' do
        expect(page.source).not_to match(google_tag)
      end
    end

    context 'and the user has not yet given or denied consent to GA cookies' do
      let(:consent) { nil }

      it 'does not render the GA tag code' do
        expect(page.source).not_to match(google_tag)
      end
    end
  end

  context 'when tracking_id is not present in Settings.google.analytics' do
    let(:tracking_id) { nil }

    context 'even if the user has given consent to GA cookies' do
      let(:consent) { 'yes' }

      it 'does not render the GA tag code' do
        expect(page.source).not_to match(google_tag)
      end
    end
  end
end
