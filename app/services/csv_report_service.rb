require 'csv'

class CsvReportService < ApplicationService
  def initialize(report_class, scope_ids:)
    @report_class = report_class
    @scope_ids = scope_ids
  end

  def call
    write_to_csv
  end

private

  attr_accessor :report_class, :path, :csv, :scope_ids

  def write_to_csv
    CSV.generate do |csv|
      report_generator_class = report_class.new(csv, scope_ids:)
      report_generator_class.generate_report
      @csv = csv
    end
  end
end
