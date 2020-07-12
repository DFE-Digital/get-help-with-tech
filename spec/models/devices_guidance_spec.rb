require 'rails_helper'

RSpec.describe DevicesGuidance, type: :model do
  subject(:guidance) { DevicesGuidance.new }

  describe '#page_exists?' do
    it 'does a slug lookup for existing pages' do
      expect(guidance.page_exists?('get-help-with-technology-devices')).to be_truthy
    end

    it 'returns false for non-existent pages' do
      expect(guidance.page_exists?('non-existent-page')).to be_falsey
    end
  end

  describe '#find_by_slug' do
    it 'fetches the page' do
      found_page = guidance.find_by_slug('get-help-with-technology-devices')

      expect(found_page).not_to be_nil
      expect(found_page.page_id).to eq(:get_help_with_technology_devices)
    end
  end
end
