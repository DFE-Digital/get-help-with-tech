class Support::ResponsibleBodyExtraMobileDataRequestsSummaryListComponent < ViewComponent::Base
  attr_accessor :responsible_body

  def initialize(responsible_body:)
    @responsible_body = responsible_body
  end

  def rows
    [
      { key: 'Requested', value: @responsible_body.extra_mobile_data_requests.requested.count },
      { key: 'In progress', value: @responsible_body.extra_mobile_data_requests.in_progress.count },
      { key: 'With a problem', value: @responsible_body.extra_mobile_data_requests.in_a_problem_state.count },
      { key: 'Complete', value: @responsible_body.extra_mobile_data_requests.complete.count },
      { key: 'Cancelled', value: @responsible_body.extra_mobile_data_requests.cancelled.count },
      { key: 'Unavailable', value: @responsible_body.extra_mobile_data_requests.unavailable.count },
    ]
  end
end
