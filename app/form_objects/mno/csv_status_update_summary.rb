class Mno::CsvStatusUpdateSummary
  attr_reader :errors, :unchanged, :updated
  def initialize
    @errors = []
    @unchanged = []
    @updated = []
  end

  def has_errors?
    @errors.present?
  end

  def has_unchanged_requests?
    @unchanged.present?
  end

  def has_updated_requests?
    @updated.present?
  end

  def add_error_record(extra_mobile_data_request)
    # to preserve incoming values these are a hash not a ExtraMobileDataRequest
    error = extra_mobile_data_request
    error[:error_message] = error[:error].join('<br/>').html_safe

    @errors << OpenStruct.new(error)
  end

  def add_unchanged_record(extra_mobile_data_request)
    @unchanged << extra_mobile_data_request
  end

  def add_updated_record(extra_mobile_data_request)
    @updated << presenter(extra_mobile_data_request)
  end

  def requests_count
    @updated.count + @unchanged.count + @errors.count
  end

  def requests_count_text
    "#{requests_count} #{'row'.pluralize(requests_count)}"
  end

  def updated_count
    @updated.count
  end

  def updated_count_text
    "#{updated_count} #{'was'.pluralize(updated_count)} updated successfully"
  end

  def unchanged_count
    @unchanged.count
  end

  def unchanged_count_text
    "#{unchanged_count} #{'was'.pluralize(unchanged_count)} not changed"
  end

  def errors_count
    @errors.count
  end

  def errors_count_text
    "#{errors_count} #{'contains'.pluralize(errors_count)} errors"
  end

  def errors_section_heading_text
    "#{errors_count} #{'request'.pluralize(errors_count)} #{'contains'.pluralize(errors_count)} errors"
  end

  def updated_section_heading_text
    "#{updated_count} #{'request'.pluralize(updated_count)} updated"
  end

private

  def presenter(extra_mobile_data_request)
    ExtraMobileDataRequestPresenter.new(extra_mobile_data_request)
  end
end
