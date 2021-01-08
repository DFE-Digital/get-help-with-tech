class SummaryListSection < SitePrism::Section
  sections :rows, SummaryListRowSection, '.govuk-summary-list__row'

  def [](key)
    rows.find { |row| row.key == key }
  end
end
