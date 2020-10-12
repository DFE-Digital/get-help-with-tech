module ComputacenterHelper
  def allow_computacenter_outgoing_api_calls(response_body: '')
    stub_request(:post, 'http://computacenter.example.com/')
      .to_return(status: 200, body: response_body, headers: {})
  end
end

RSpec.configure do |c|
  c.include ComputacenterHelper
end
