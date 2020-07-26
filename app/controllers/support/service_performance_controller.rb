class Support::ServicePerformanceController < Support::BaseController
  def index
    @service_performance = ServicePerformance.new
  end
end
