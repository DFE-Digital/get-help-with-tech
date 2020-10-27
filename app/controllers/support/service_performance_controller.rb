class Support::ServicePerformanceController < Support::BaseController
  def index
    @stats = Support::ServicePerformance.new
  end
end
