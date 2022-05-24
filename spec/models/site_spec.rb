require 'rails_helper'

RSpec.describe Site, type: :model do
  describe '#banner_message' do
    context 'default no site banner message text present' do
      it 'returns the banner message from the settings' do
        allow(Settings).to receive(:site_banner_message).and_return(nil)
        expect(Site.banner_message).to eq(nil)
      end
    end

    context 'site banner message text present' do
      it 'returns the banner message from the settings' do
        allow(Settings).to receive(:site_banner_message).and_return('This is a test short form banner message')
        expect(Site.banner_message).to eq('This is a test short form banner message')
      end
    end
  end

  describe '#long_form_banner_message_flag?' do
    it 'returns the long form banner message flag from the settings when "False"' do
      allow(Settings).to receive(:long_form_site_banner_message_flag).and_return('False')
      expect(Site.long_form_banner_message_flag?).to eq(false)
    end

    it 'returns the long form banner message flag from the settings when "0"' do
      allow(Settings).to receive(:long_form_site_banner_message_flag).and_return('0')
      expect(Site.long_form_banner_message_flag?).to eq(false)
    end

    it 'returns the long form banner message flag from the settings when "True"' do
      allow(Settings).to receive(:long_form_site_banner_message_flag).and_return('True')
      expect(Site.long_form_banner_message_flag?).to eq(true)
    end

    it 'returns the long form banner message flag from the settings when "1"' do
      allow(Settings).to receive(:long_form_site_banner_message_flag).and_return('1')
      expect(Site.long_form_banner_message_flag?).to eq(true)
    end

    it 'returns the long form banner message flag from the settings when "nil"' do
      allow(Settings).to receive(:long_form_site_banner_message_flag).and_return(nil)
      expect(Site.long_form_banner_message_flag?).to eq(false)
    end
  end

  describe '#long_form_site_banner_message_partial' do
    it 'returns the long form banner message partial' do
      allow(Settings).to receive(:long_form_site_banner_message_partial).and_return('site_banner/long_form')
      expect(Site.long_form_site_banner_message_partial).to eq('site_banner/long_form')
    end
  end
end
