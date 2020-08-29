class Support::Devices::ServicePerformanceController < Support::BaseController
  def index
    @stats = Support::Devices::ServicePerformance.new
  end
end
