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
        update_status!(record, request)
      else
        # could not find record
        request[:error] = ['We could not find this request']
        summary.add_error_record(request)
      end
    end
    summary
  end

private

  def update_status!(record, request)
    status = request[:status]
    if status.blank?
      request[:error] = ['No status provided']
      summary.add_error_record(request)
    elsif status.in?(ExtraMobileDataRequest.statuses_that_mno_users_can_use_in_csv_uploads)
      if record.status != status
        record.update!(status:)
        summary.add_updated_record(record)
      else
        summary.add_unchanged_record(record)
      end
    else
      request[:error] = ["'#{status}' is not a valid status"]
      summary.add_error_record(request)
    end
  end
end
