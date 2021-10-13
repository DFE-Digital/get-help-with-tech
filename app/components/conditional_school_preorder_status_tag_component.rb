class ConditionalSchoolPreorderStatusTagComponent < SchoolPreorderStatusTagComponent
  def initialize(school:, viewer: nil)
    super
  end

  def should_show_status?
    case @school.preorder_information&.who_will_order_devices
    when 'responsible_body'
      status.in? statuses_to_display
    when 'school'
      status.in?(statuses_to_display + %w[ordered])
    else
      true
    end
  end

private

  def statuses_to_display
    %w[needs_contact needs_info school_contacted school_will_be_contacted].freeze
  end
end
