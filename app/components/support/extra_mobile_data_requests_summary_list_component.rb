class Support::ExtraMobileDataRequestsSummaryListComponent < ViewComponent::Base
  attr_accessor :requests

  def initialize(requests:)
    @requests = requests
  end

  def rows
    [
      { key: 'New', value: @requests.new_status.count },
      { key: 'In progress', value: @requests.in_progress_status.count },
      { key: 'With a problem', value: @requests.in_a_problem_state.count },
      { key: 'Complete', value: @requests.complete_status.count },
      { key: 'Cancelled', value: @requests.cancelled_status.count },
      { key: 'Unavailable', value: @requests.unavailable_status.count },
    ]
  end
end
