class ConditionalSchoolPreorderStatusTagComponent < SchoolPreorderStatusTagComponent
  def initialize(school:, viewer: nil)
    super
  end

  def should_show_status?
    return status.in?(statuses_to_display) if @school.orders_managed_centrally?
    return status.in?(statuses_to_display + %w[ordered]) if @school.orders_managed_by_school?

    true
  end

private

  def statuses_to_display
    %w[needs_contact needs_info school_contacted school_will_be_contacted].freeze
  end
end
