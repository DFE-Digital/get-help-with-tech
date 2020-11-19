class Support::ServicePerformanceController < Support::BaseController
  before_action { authorize Support::ServicePerformance }

  def index
    skip_policy_scope
    @stats = Support::ServicePerformance.new
  end
end
