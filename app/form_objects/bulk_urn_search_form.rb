class BulkUrnSearchForm
  include ActiveModel::Model

  attr_accessor :urns

  def array_of_urns
    @array_of_urns ||= urns.split("\r\n").map(&:strip).reject(&:blank?)
  end

  def request_count
    array_of_urns.size
  end

  def missing_count
    request_count - result_count
  end

  def result_count
    schools.count
  end

  def schools
    @schools ||= School.where(urn: array_of_urns)
  end

  def missing_urns
    array_of_urns - schools.pluck(:urn).map(&:to_s)
  end
end
