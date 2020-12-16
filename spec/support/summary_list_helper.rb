module SummaryListHelper
  def row_for_key(doc, key)
    doc.css('.govuk-summary-list__row').find { |row| row.css('dt').text.strip == key }
  end

  def value_for_row(doc, key)
    row = row_for_key(doc, key)
    row.css('dd')[0]
  end

  def action_for_row(doc, key)
    row = row_for_key(doc, key)
    row.css('dd')[1]
  end
end

RSpec.configure do |c|
  c.include SummaryListHelper
end
