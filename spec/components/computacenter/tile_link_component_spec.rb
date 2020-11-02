require 'rails_helper'

RSpec.describe Computacenter::TileLinkComponent, type: :component do
  subject(:tile) { described_class.new(count: 3, path: '/my/resource/path', label: 'blind mice') }

  it 'renders the count' do
    expect(rendered_result_text).to include('3')
  end

  it 'renders the label' do
    expect(rendered_result_text).to include('blind mice')
  end

  it 'renders a link to the path' do
    render_inline(tile)
    expect(page).to have_selector("a[href='/my/resource/path']")
  end

  describe 'a tile with an overridden colour' do
    subject(:tile) { described_class.new(count: 3, label: 'blind mice', path: '/my/resource/path', colour: :blue) }

    it 'applies the override CSS class' do
      expect(rendered_result_html).to include('app-card--blue')
    end
  end

  describe 'a secondary tile' do
    subject(:tile) { described_class.new(count: 3, label: 'blind mice', path: '/my/resource/path', size: :secondary) }

    it 'has different (smaller) text' do
      expect(rendered_result_html).to include('app-card__secondary-count')
    end
  end

  def rendered_result_html
    render_inline(tile).to_html
  end

  def rendered_result_text
    render_inline(tile).text
  end
end
