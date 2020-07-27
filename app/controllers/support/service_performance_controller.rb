class Support::ServicePerformanceController < Support::BaseController
  def index
    @stats = ServicePerformance.new
  end
end
