class ExtraMobileDataRequestStatusImporter
  attr_reader :summary

  def initialize(mobile_network:, datasource:)
    @mno = mobile_network
    @datasource = datasource
    @summary = Mno::CsvStatusUpdateSummary.new
  end

  def import!
    @datasource.requests do |request|
      record = @mno.extra_mobile_data_requests.find_by(id: request[:id])
      if record
        if account_holder_valid?(record, request) &&
            phone_number_valid?(record, request) &&
            status_valid?(record, request)
          if record.status != request[:status]
            record.status = request[:status]
            record.save!
            summary.add_updated_record(record)
          else
            summary.add_unchanged_record(record)
          end
        end
      else
        # could not find record
        request[:error] = ['We could not find this request']
        summary.add_error_record(request)
      end
    end
    summary
  end

private

  def account_holder_valid?(record, request)
    if record.account_holder_name == request[:account_holder_name]
      true
    else
      request[:error] = ['Account holder does not match our records',
                         "We expected #{record.account_holder_name}"]
      summary.add_error_record(request)
      false
    end
  end

  def phone_number_valid?(record, request)
    if Phonelib.parse(record.device_phone_number).national(false) == Phonelib.parse(request[:device_phone_number]).national(false)
      true
    else
      request[:error] = ['Phone number does not match our records',
                         "We expected #{record.device_phone_number}"]
      summary.add_error_record(request)
      false
    end
  end

  def status_valid?(_record, request)
    status = request[:status]
    if status.blank?
      request[:error] = ['No status provided']
      summary.add_error_record(request)
      false
    elsif status.in?(ExtraMobileDataRequest.statuses_that_mno_users_can_use_in_csv_uploads)
      true
    else
      request[:error] = ["'#{status}' is not a valid status"]
      summary.add_error_record(request)
      false
    end
  end
end
