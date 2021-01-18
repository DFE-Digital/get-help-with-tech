class ExtraMobileDataRequestStatusComponent < ViewComponent::Base
  def initialize(extra_mobile_data_request:)
    @extra_mobile_data_request = extra_mobile_data_request
  end

  def colour
    case @extra_mobile_data_request.status.to_sym
    when :requested then 'blue'
    when :in_progress then 'yellow'
    when :complete then 'green'
    when :queried, :problem_incorrect_phone_number, :problem_no_match_for_number, :problem_no_match_for_account_name, :problem_not_eligible, :problem_no_longer_on_network then 'red'
    when :cancelled, :unavailable then 'grey'
    end
  end

  def status
    @extra_mobile_data_request.status
  end

  def label
    if @extra_mobile_data_request.status.start_with?('problem')
      I18n.t!(@extra_mobile_data_request.status, scope: %i[activerecord attributes extra_mobile_data_request problem_tags])
    elsif @extra_mobile_data_request.queried?
      I18n.t!("problem_#{@extra_mobile_data_request.problem}", scope: %i[activerecord attributes extra_mobile_data_request problem_tags])
    else
      @extra_mobile_data_request.translated_enum_value(:status)
    end
  end
end
