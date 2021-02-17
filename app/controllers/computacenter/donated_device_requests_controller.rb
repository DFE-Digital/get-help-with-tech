class Computacenter::DonatedDeviceRequestsController < Computacenter::BaseController
  def index
    respond_to do |format|
      format.csv do
        send_data DonatedDeviceRequestsExporter.new.export, filename: "donated-device-requests-#{Time.zone.now.iso8601}.csv"
      end
    end
  end
end
