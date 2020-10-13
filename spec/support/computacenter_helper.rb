module ComputacenterHelper
  def stub_computacenter_outgoing_api_calls(response_body: '', response_status: 200)
    stub_request(:post, 'http://computacenter.example.com/')
      .to_return(status: response_status, body: response_body, headers: {})
  end
end

RSpec.configure do |c|
  c.include ComputacenterHelper
end
