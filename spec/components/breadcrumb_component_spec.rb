require 'rails_helper'

RSpec.describe BreadcrumbComponent do
  it 'renders breadcrumb items from the provided list' do
    items = [
      { label: 'GOV.UK', path: 'https://www.gov.uk' },
      { label: 'BBC', path: 'https://www.bbc.co.uk' },
    ]
    result = render_inline(BreadcrumbComponent.new(items))

    expect(result.css('.govuk-breadcrumbs li a')[0].text).to eq('GOV.UK')
    expect(result.css('.govuk-breadcrumbs li a')[0].attr('href')).to eq('https://www.gov.uk')

    expect(result.css('.govuk-breadcrumbs li a')[1].text).to eq('BBC')
    expect(result.css('.govuk-breadcrumbs li a')[1].attr('href')).to eq('https://www.bbc.co.uk')
  end

  it 'renders a list of key-values correctly' do
    items = [
      { 'GOV.UK' => 'https://www.gov.uk' },
      { 'BBC' => 'https://www.bbc.co.uk' },
    ]
    result = render_inline(BreadcrumbComponent.new(items))

    expect(result.css('.govuk-breadcrumbs li a')[0].text).to eq('GOV.UK')
    expect(result.css('.govuk-breadcrumbs li a')[0].attr('href')).to eq('https://www.gov.uk')

    expect(result.css('.govuk-breadcrumbs li a')[1].text).to eq('BBC')
    expect(result.css('.govuk-breadcrumbs li a')[1].attr('href')).to eq('https://www.bbc.co.uk')
  end

  it 'renders string items as strings' do
    items = [
      { 'GOV.UK' => 'https://www.gov.uk' },
      'BBC',
    ]
    result = render_inline(BreadcrumbComponent.new(items))

    expect(result.css('.govuk-breadcrumbs li a')[0].text).to eq('GOV.UK')
    expect(result.css('.govuk-breadcrumbs li a')[0].attr('href')).to eq('https://www.gov.uk')

    expect(result.css('.govuk-breadcrumbs li')[1].inner_html.strip).to eq('BBC')
  end
end
