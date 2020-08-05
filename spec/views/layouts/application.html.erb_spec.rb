require 'rails_helper'

RSpec.describe 'application layout', type: :view do
  describe 'Google Analytics behaviour' do
    context 'when tracking_id is present in Settings.google.analytics' do
      before do
        allow(Settings.google.analytics).to receive(:tracking_id).and_return('MYTRACKING-ID')
        render template: 'layouts/application'
      end

      it 'renders the GA tag code' do
        expect(rendered).to match('<script async src="https://www.googletagmanager.com/gtag/js')
      end
    end

    context 'when tracking_id is not present in Settings.google.analytics' do
      before do
        allow(Settings.google.analytics).to receive(:tracking_id).and_return('')
        render template: 'layouts/application'
      end

      it 'does not render the GA tag code' do
        expect(rendered).not_to match('<script async src="https://www.googletagmanager.com/gtag/js')
      end
    end
  end
end
