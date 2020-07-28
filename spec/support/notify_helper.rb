module NotifyHelper
  def stub_notify_request
    WebMock.stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/sms').to_return(
      status: 201,
      body: success_response_body,
      headers: { content_type: 'application/json' },
    )
  end

  def success_response_body
    File.new(Rails.root.join('spec/support/data/notify_success_body.json'))
  end
end
