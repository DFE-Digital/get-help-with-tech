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
        if record.account_holder_name != request[:account_holder_name]
          request[:error] = ['Account holder does not match our records',
                             "We expected #{record.account_holder_name}"]
          summary.add_error_record(request)
        elsif record.device_phone_number != request[:device_phone_number]
          request[:error] = ['Phone number does not match our records',
                             "We expected #{record.device_phone_number}"]
          summary.add_error_record(request)
        elsif request[:status].blank?
          request[:error] = ['No status provided']
          summary.add_error_record(request)
        elsif is_valid_status?(request[:status])
          if record.status != request[:status]
            record.status = request[:status]
            record.save!
            summary.add_updated_record(record)
          else
            summary.add_unchanged_record(record)
          end
        else
          # invalid status
          request[:error] = ["'#{request[:status]}' is not a valid status"]
          summary.add_error_record(request)
        end
      end
    end
    summary
  end

private

  def is_valid_status?(status)
    ExtraMobileDataRequest.statuses.include? status
  end
end
