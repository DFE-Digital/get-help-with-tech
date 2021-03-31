require 'rails_helper'

RSpec.describe MultipartGuidance, type: :model do
  subject(:guidance) { described_class.new(metadata) }

  let(:metadata) do
    [
      {
        page_id: :overview,
        path: '/guide/overview',
        title: 'Overview',
        description: 'The overview of the guide',
        guidance_section: 'usergroup_1',
      },
      {
        page_id: :second_page,
        path: '/guide/second-page',
        title: 'Another page',
        description: 'More details',
        guidance_section: 'usergroup_1',
      },
      {
        page_id: :third_page,
        path: '/guide/third-page',
        title: 'Last page',
        description: 'Finally',
        guidance_section: 'usergroup_2',
      },
    ]
  end

  describe '#page_exists?' do
    it 'does a slug lookup for existing pages' do
      expect(guidance.page_exists?('second-page')).to be_truthy
    end

    it 'returns false for non-existent pages' do
      expect(guidance.page_exists?('non-existent-page')).to be_falsey
    end
  end

  describe '#find_by_slug' do
    it 'fetches the page' do
      found_page = guidance.find_by_slug('third-page')

      expect(found_page).not_to be_nil
      expect(found_page.page_id).to eq(:third_page)
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

      expected_titles_in_order = ['Overview', 'Another page', 'Last page']
      expect(actual_titles).to eq(expected_titles_in_order)
    end

    it 'cross-links the pages so they can be navigated backwards' do
      current_page = guidance.all_pages.last
      actual_titles = []

      while current_page
        actual_titles << current_page.title
        current_page = current_page.previous
      end

      expected_titles_in_reverse_order = ['Last page', 'Another page', 'Overview']
      expect(actual_titles).to eq(expected_titles_in_reverse_order)
    end
  end

  describe '#pages_for' do
    it 'filters the pages by guidance_section' do
      expect(guidance.pages_for(guidance_section: :usergroup_1).map(&:page_id)).to eq(%i[overview second_page])

      expect(guidance.pages_for(guidance_section: :usergroup_2).map(&:page_id)).to eq(%i[third_page])
    end
  end
end
