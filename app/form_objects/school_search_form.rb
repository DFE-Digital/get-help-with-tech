class SchoolSearchForm
  include ActiveModel::Model

  attr_accessor :urns, :responsible_body_id, :order_state

  def array_of_urns
    @array_of_urns ||= urns.to_s.split("\r\n").map(&:strip).reject(&:blank?)
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
    school_records = School.gias_status_open
    school_records = school_records.where(urn: array_of_urns) if array_of_urns.present?
    school_records = school_records.where(responsible_body_id: responsible_body_id) if responsible_body_id.present?
    school_records = school_records.where(order_state: order_state) if order_state.present?

    @schools ||= school_records
  end

  def missing_urns
    array_of_urns - schools.pluck(:urn).map(&:to_s)
  end

  def select_responsible_body_options
    ResponsibleBody.order(:name).pluck(:id, :name).map { |id, name|
      OpenStruct.new(id: id, name: name)
    }.prepend(OpenStruct.new(id: nil, name: '(all)'))
  end

  def select_order_state_options
    School.translated_enum_values(:order_states).prepend(OpenStruct.new(value: nil, label: '(all)'))
  end
end
