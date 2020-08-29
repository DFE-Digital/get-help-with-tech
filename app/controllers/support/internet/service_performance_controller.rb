class Support::Internet::ServicePerformanceController < Support::BaseController
  def index
    @stats = Support::Internet::ServicePerformance.new
  end
end
