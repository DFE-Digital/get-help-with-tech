require 'rails_helper'

RSpec.describe 'Cache header on static assets', type: :feature do
  context 'when requesting a static asset' do
    before do
      visit('/')
      first_image = page.html.match(/.+"(\/packs\/[^"]+)".+/).captures.first
      visit(first_image)
    end

    it 'has a Cache-Control header with a max-age value' do
      expect(response_headers['Cache-Control']).to include('max-age=')
    end
  end
end
