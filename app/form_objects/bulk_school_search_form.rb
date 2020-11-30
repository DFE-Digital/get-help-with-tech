class BulkSchoolSearchForm
  include ActiveModel::Model

  attr_accessor :identifiers

  def array_of_identifiers
    @array_of_identifiers ||= identifiers.split("\r\n").map(&:strip).reject(&:blank?)
  end

  def request_count
    array_of_identifiers.size
  end

  def missing_count
    request_count - result_count
  end

  def result_count
    schools.count
  end

  def schools
    @schools ||= School.gias_status_open.where(urn: array_of_identifiers).or(School.gias_status_open.where(ukprn: array_of_identifiers))
  end

  def missing_identifiers
    array_of_identifiers - [schools.pluck(:urn), schools.pluck(:ukprn)].flatten.map(&:to_s)
  end
end
