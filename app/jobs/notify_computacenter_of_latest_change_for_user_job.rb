class NotifyComputacenterOfLatestChangeForUserJob < ApplicationJob
  queue_as :default

  # NOTE: we only pass the allocation_ids, not the amounts to update the caps to.
  # This way, the new caps get read at the time the job is performed rather than
  # when it was scheduled - so if there are several jobs queued up, it doesn't
  # matter if the jobs get processed in the right order or not, the last job
  # processed will always set the latest value.
  def perform(user_id)
    @latest_change = Computacenter::UserChange.latest_for_user(User.find(user_id))
    @request = construct_request
    @response = @request.post!
    record_transaction!
    @response
  end

private

  def construct_request
    Computacenter::ServiceNowUserImportAPI::ImportUserChangeRequest.new(
      user_change: @latest_change,
    )
  end

  def record_transaction!
    @latest_change.update!(
      cc_import_api_timestamp: @request.timestamp,
      cc_import_api_transaction_id: @request.cc_transaction_id,
    )
  end
end
