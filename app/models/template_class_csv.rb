class TemplateClassCsv
  def initialize(csv, scope_ids:)
    @csv = csv
    @scope_ids = scope_ids
  end

  def generate_report
    add_headers
    add_report_rows
  end

private

  attr_accessor :csv, :scope_ids

  def add_headers
    raise NotImplementedError
  end

  def add_report_rows
    raise NotImplementedError
  end
end
