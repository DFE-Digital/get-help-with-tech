class NotifyComputacenterOfLatestChangeForUserJob < ApplicationJob
  queue_as :default

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
