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
      expect(a_request(:post, 'http://computacenter.example.com/').with { |req|
        result = Nokogiri::XML(req.body)
        result.css('CapAdjustmentRequest Record').to_a.map(&:to_h).map(&:to_a).sort == caps.map(&:to_a).sort
      }).to have_been_made
    end
  end

  def expect_not_to_have_sent_caps_to_computacenter
    expect(a_request(:post, 'http://computacenter.example.com/')).not_to have_been_made
  end

  # let(:mock_request) do
  #   instance_double(Computacenter::OutgoingAPI::CapUpdateRequest,
  #                   timestamp: Time.current,
  #                   payload_id: '123456789',
  #                   body: '<xml>test-request</xml>').as_null_object
  # end
  #
  # before do
  #   allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
  # end
  #
  # it "" do
  #   expect(mock_request).to have_received(:post)
  #   expect(Computacenter::OutgoingAPI::CapUpdateRequest).to have_received(:new).with(
  #     [
  #      OpenStruct.new(cap_type: 'DfE_RemainThresholdQty|Coms_Device',
  #                     ship_to: '12',
  #                     cap: 2),
  #      OpenStruct.new(cap_type: 'DfE_RemainThresholdQty|Std_Device',
  #                     ship_to: '12',
  #                     cap: 2),
  #     ]
  #   )
  # end

end

RSpec.configure do |c|
  c.include ComputacenterHelper
end
