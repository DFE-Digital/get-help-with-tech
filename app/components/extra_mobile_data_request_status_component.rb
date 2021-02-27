class ExtraMobileDataRequestStatusComponent < ViewComponent::Base
  attr_reader :status

  def initialize(status:, viewer: :school_or_mno_user)
    @status = status.to_sym
    @viewer = viewer
  end

  def colour
    case @status
    when :new then 'blue'
    when :in_progress then 'yellow'
    when :complete then 'green'
    when /problem_/ then 'red'
    when :cancelled, :unavailable then 'grey'
    end
  end

  def label
    if @viewer == :school_or_mno_user && @status == :new
      # This override only happens for one status and it felt better to put
      # the logic here rather than have separate `tag_status` values for MNO
      # and school/RB users in en.yml
      'Requested'
    else
      I18n.t!(
        "#{@status}.tag_label",
        scope: %i[activerecord attributes extra_mobile_data_request status],
      )
    end
  end
end
