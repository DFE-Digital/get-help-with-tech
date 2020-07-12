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

  describe '#all_pages' do
    it 'returns all the pages' do
      expect(guidance.all_pages).not_to be_empty
    end

    it 'cross-links the pages so they can be navigated forwards' do
      current_page = guidance.all_pages.first
      actual_titles = []

      while current_page
        actual_titles << current_page.title
        current_page = current_page.next
      end

      expected_titles_in_order = I18n.t!('devices_guidance').values.map { |attributes| attributes[:title] }
      expect(actual_titles).to eq(expected_titles_in_order)
    end

    it 'cross-links the pages so they can be navigated backwards' do
      current_page = guidance.all_pages.last
      actual_titles = []

      while current_page
        actual_titles << current_page.title
        current_page = current_page.previous
      end

      expected_titles_in_order = I18n
        .t!('devices_guidance')
        .values
        .map { |attributes| attributes[:title] }
        .reverse
      expect(actual_titles).to eq(expected_titles_in_order)
    end
  end
end
