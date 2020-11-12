class Support::ServicePerformanceController < Support::BaseController
  before_action { authorize :support }

  def index
    @stats = Support::ServicePerformance.new
  end
end
