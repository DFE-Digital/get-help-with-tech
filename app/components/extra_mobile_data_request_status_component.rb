class ExtraMobileDataRequestStatusComponent < ViewComponent::Base
  def initialize(extra_mobile_data_request:, viewer: :school_or_mno_user)
    @extra_mobile_data_request = extra_mobile_data_request
    @viewer = viewer
  end

  def colour
    case @extra_mobile_data_request.status.to_sym
    when :new then 'blue'
    when :in_progress then 'yellow'
    when :complete then 'green'
    when :problem_incorrect_phone_number, :problem_no_match_for_number, :problem_no_match_for_account_name, :problem_not_eligible, :problem_no_longer_on_network then 'red'
    when :cancelled, :unavailable then 'grey'
    end
  end

  def status
    @extra_mobile_data_request.status
  end

  def label
    if @viewer == :school_or_mno_user && @extra_mobile_data_request.new_status?
      # This override only happens for one status and it felt better to put
      # the logic here rather than have separate `tag_status` values for MNO
      # and school/RB users in en.yml
      'Requested'
    else
      I18n.t!(
        "#{@extra_mobile_data_request.status}.tag_label",
        scope: %i[activerecord attributes extra_mobile_data_request status],
      )
    end
  end
end
