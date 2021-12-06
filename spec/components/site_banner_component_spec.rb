require 'rails_helper'

RSpec.describe SiteBannerComponent, type: :component do
  subject { render_inline(described_class.new(message: 'Site wide banner message text')) }

  context 'banner message present' do
    it { is_expected.to have_css('#site-banner-component') }
  end

  context 'no banner message present' do
    subject { render_inline(described_class.new) }

    it { is_expected.to have_no_css('#site-banner-component') }
  end
end
