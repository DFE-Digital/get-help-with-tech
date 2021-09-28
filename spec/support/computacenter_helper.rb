module ComputacenterHelper
  def stub_computacenter_outgoing_api_calls(response_body: '', response_status: 200)
    stub_request(:post, 'http://computacenter.example.com/')
      .to_return(status: response_status, body: response_body, headers: {})
  end

  def expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: true)
    if check_number_of_calls
      expect(a_request(:post, 'http://computacenter.example.com/')).to have_been_made.times(requests.size)
    end
    requests.each do |caps|
      expect(a_request(:post, 'http://computacenter.example.com/').with do |req|
        result = Nokogiri::XML(req.body)
        result.css('CapAdjustmentRequest Record').to_a.map(&:to_h).map(&:to_a).sort == caps.map(&:to_a).sort
      end).to have_been_made
    end
  end

  def expect_not_to_have_sent_caps_to_computacenter
    expect(a_request(:post, 'http://computacenter.example.com/')).not_to have_been_made
  end
end

RSpec.configure do |c|
  c.include ComputacenterHelper
end
