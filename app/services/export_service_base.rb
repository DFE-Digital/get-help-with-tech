require 'csv'

# Service to export data
class ExportServiceBase < ApplicationService
  def initialize(report_class, scope_ids:)
    @report_class = report_class
    @scope_ids = scope_ids
  end

  def call
    CsvReportService.call(report_class, scope_ids:)
  end

private

  attr_reader :report_class, :scope_ids
end
