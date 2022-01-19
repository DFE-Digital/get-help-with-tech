require 'rails_helper'

describe SummaryListComponent do
  it 'renders component with correct structure' do
    rows = [
      key: 'Name:',
      value: 'Lando Calrissian',
      action: 'Name',
      change_path: '/some/url',
    ]
    result = render_inline(SummaryListComponent.new(rows: rows))

    expect(result.css('.govuk-summary-list__key').text).to include('Name:')
    expect(result.css('.govuk-summary-list__value').text).to include('Lando Calrissian')
    expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include('/some/url')
    expect(result.css('.govuk-summary-list__actions').text).to include('Change Name')
  end

  it 'renders arrays content when passed in' do
    rows = [
      key: 'Address:',
      value: ['Whoa Drive', 'Wewvile', 'London'],
      action: 'Name',
      change_path: '/some/url',
    ]
    result = render_inline(SummaryListComponent.new(rows: rows))

    expect(result.css('.govuk-summary-list__value').to_html).to include('Whoa Drive<br>Wewvile<br>London')
  end

  it 'renders component with correct struture using action_path' do
    rows = [
      key: 'Please enter the sound a cat makes',
      value: 'Meow',
      action: 'Enter cat sounds',
      action_path: '/cat/sounds',
    ]
    result = render_inline(SummaryListComponent.new(rows: rows))

    expect(result.css('.govuk-summary-list__key').text).to include('Please enter the sound a cat makes')
    expect(result.css('.govuk-summary-list__value').text).to include('Meow')
    expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include('/cat/sounds')
    expect(result.css('.govuk-summary-list__actions').text).to include('Enter cat sounds')
  end

  it 'renders HTML in values when safe' do
    rows = [
      key: 'Safe',
      value: '<span class="safe-html">This is safe</span>'.html_safe,
    ]

    result = render_inline(SummaryListComponent.new(rows: rows))
    expect(result.css('.govuk-summary-list__value > .safe-html').text).to include('This is safe')
  end

  it 'uses simple_format to convert line breaks and strip HTML' do
    rows = [
      key: 'Unsafe',
      value: '<span class="unsafe-html"><script>Unsafe</script></span>',
    ]

    result = render_inline(SummaryListComponent.new(rows: rows))
    expect(result.css('.govuk-summary-list__value p').to_html).to eq('<p class="govuk-body">Unsafe</p>')
  end

  context 'no row has an action' do
    it 'does not add no-actions class to any of the rows' do
      rows = [{ key: 'Job',
                value: ['Teacher', 'Clearcourt High'] },
              { key: 'Working pattern',
                value: "Full-time\n Omnis itaque rerum. Velit in ." },
              { key: 'Description',
                value: 'Cumque autem veritatis..' },
              { key: 'Dates',
                value: 'May 2003 - November 2019' }]

      result = render_inline(SummaryListComponent.new(rows: rows))

      expect(result.to_html).not_to include('govuk-summary-list__row--no-actions')
    end
  end

  context 'mix of rows with and without actions' do
    it 'adds no-actions class to rows without actions' do
      rows = [{ key: 'Job',
                value: ['Teacher', 'Clearcourt High'] },
              { key: 'Working pattern',
                value: "Full-time\n Omnis itaque rerum. Velit in ." },
              { key: 'Description',
                value: 'Cumque autem veritatis..' },
              { key: 'Dates',
                value: 'May 2003 - November 2019',
                action: 'dates for Teacher, Clearcourt High',
                action_path: '/some/url' }]

      result = render_inline(SummaryListComponent.new(rows: rows))

      expect(result.to_html).to include('govuk-summary-list__row--no-actions').at_least(3).times
    end

    it 'adds no-actions class to rows without actions - change_path option' do
      rows = [{ key: 'Job',
                value: ['Teacher', 'Clearcourt High'] },
              { key: 'Working pattern',
                value: "Full-time\n Omnis itaque rerum. Velit in ." },
              { key: 'Description',
                value: 'Cumque autem veritatis..' },
              { key: 'Dates',
                value: 'May 2003 - November 2019',
                change_path: '/some/url' }]

      result = render_inline(SummaryListComponent.new(rows: rows))

      expect(result.to_html).to include('govuk-summary-list__row--no-actions').at_least(3).times
    end
  end
end
