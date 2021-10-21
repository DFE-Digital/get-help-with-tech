require 'rails_helper'

RSpec.describe StartPageBannerComponent, type: :component do
  subject { render_inline(described_class.new) }

  context 'signed out' do
    before { allow(SessionService).to receive(:is_signed_in?).and_return(false) }

    it { is_expected.to have_css('#sign_in') }
  end

  context 'signed in' do
    before { allow(SessionService).to receive(:is_signed_in?).and_return(true) }

    it { is_expected.to have_no_css('#sign_in') }
  end
end
