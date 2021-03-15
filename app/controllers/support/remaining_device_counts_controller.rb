class Support::RemainingDeviceCountsController < Support::BaseController
  before_action { authorize Support::ServicePerformance }

  def index
    respond_to do |format|
      format.csv do
        send_data RemainingDeviceCount.to_csv, filename: "remaining_device_counts-#{file_date}.csv"
      end
    end
  end

private

  def file_date
    RemainingDeviceCount.most_recent.date_of_count.strftime('%Y%m%d')
  end

  def service
    @service ||= RemainingDevicesCalculator.new
  end
end
