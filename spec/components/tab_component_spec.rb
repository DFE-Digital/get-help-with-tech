require 'rails_helper'

RSpec.describe TabComponent, type: :component do
  subject(:tab) { described_class.new(path: '/my/resource/path', label: '3 blind mice', selected: false) }

  it 'renders a list item with the correct govuk classes' do
    render_inline(tab)
    expect(page).to have_selector('li.govuk-tabs__list-item')
  end

  it 'renders the label as a link to the path' do
    render_inline(tab)
    expect(page).to have_selector("a[href='/my/resource/path']", text: '3 blind mice')
  end

  context 'when selected is true' do
    subject(:tab) { described_class.new(path: '/my/resource/path', label: '3 blind mice', selected: true) }

    it 'renders the list item with an extra html class' do
      render_inline(tab)
      expect(page).to have_selector('li.govuk-tabs__list-item.govuk-tabs__list-item--selected')
    end
  end
end
