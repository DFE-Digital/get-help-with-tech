class ExtraMobileDataRequestStatusComponent < ViewComponent::Base
  def initialize(extra_mobile_data_request:)
    @extra_mobile_data_request = extra_mobile_data_request
  end

  def colour
    {
      requested: 'blue',
      in_progress: 'yellow',
      complete: 'green',
      queried: 'red',
      cancelled: 'grey',
      unavailable: 'grey',
    }[@extra_mobile_data_request.status.to_sym]
  end

  def status
    @extra_mobile_data_request.status
  end

  def label
    if @extra_mobile_data_request.queried?
      I18n.t(@extra_mobile_data_request.problem, scope: %i[activerecord attributes extra_mobile_data_request problem_tags])
    else
      @extra_mobile_data_request.translated_enum_value(:status)
    end
  end
end
