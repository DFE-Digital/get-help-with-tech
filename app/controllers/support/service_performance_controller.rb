class Support::ServicePerformanceController < Support::BaseController
  before_action { authorize Support::ServicePerformance }

  def index
    skip_policy_scope
    @completion_date_form = Support::RequestCompletionsForm.new(performance_params)
    @stats = Support::ServicePerformance.new
  end

  def mno_requests
    skip_policy_scope

    exporter = Exporters::MnoRequestsCsv.new
    exporter.call
    now = Time.zone.now

    send_file exporter.path, filename: "mno-requests-#{now.strftime('%Y')}-#{now.strftime('%m')}-#{now.strftime('%d')}.csv", type: 'text/csv'
  end

private

  def performance_params
    params.fetch(:completions, {}).permit(:from, :to)
  end
end
