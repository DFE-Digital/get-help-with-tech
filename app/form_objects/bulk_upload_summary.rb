class BulkUploadSummary
  attr_reader :errors, :existing, :successful

  def initialize
    @errors = []
    @existing = []
    @successful = []
  end

  def has_errors?
    @errors.present?
  end

  def has_successful_requests?
    @successful.present?
  end

  def add_error_record(extra_mobile_data_request)
    @errors << presenter(extra_mobile_data_request)
  end

  def add_existing_record(extra_mobile_data_request)
    @existing << extra_mobile_data_request
  end

  def add_successful_record(extra_mobile_data_request)
    @successful << presenter(extra_mobile_data_request)
  end

  def requests_count
    @successful.count + @existing.count + @errors.count
  end

  def requests_count_text
    "#{requests_count} #{'row'.pluralize(requests_count)}"
  end

  def successful_count
    @successful.count
  end

  def successful_count_text
    "#{successful_count} #{'was'.pluralize(successful_count)}"
  end

  def existing_count
    @existing.count
  end

  def existing_count_text
    "#{existing_count} #{'was'.pluralize(existing_count)}"
  end

  def errors_count
    @errors.count
  end

  def errors_count_text
    "#{errors_count} #{'contains'.pluralize(errors_count)}"
  end

  def errors_section_heading_text
    "#{errors_count} #{'request'.pluralize(errors_count)} #{'contains'.pluralize(errors_count)} errors"
  end

  def uploaded_section_heading_text
    "#{successful_count} #{'request'.pluralize(successful_count)} uploaded"
  end

private

  def presenter(extra_mobile_data_request)
    ExtraMobileDataRequestPresenter.new(extra_mobile_data_request)
  end
end
