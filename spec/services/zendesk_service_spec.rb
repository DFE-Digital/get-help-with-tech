require 'rails_helper'

RSpec.describe ZendeskService, type: :model do
  subject(:service) { ZendeskService.new(support_ticket) }

  let(:support_ticket) do
    SupportTicket.new(
      full_name: 'Joe Blogg',
      email_address: 'joe@bloggs.com',
      user_type: 'parent',
      telephone_number: '0207 333 4444',
      message: 'This is my query',
      support_topics: %w[hello world],
      user_profile_path: nil,
    )
  end

  describe '#send!' do
    it 'calls ZendeskAPI::Request.create!' do
      allow(ZendeskAPI::Request).to receive(:create!)
      service.send!
      expect(ZendeskAPI::Request).to have_received(:create!)
    end

    it 'makes the expected request, with common and custom fields' do
      call_to_zendesk = stub_request(:post, 'https://get-help-with-tech-education.zendesk.com/api/v2/requests')
        .with(
          body: '{"request":{"requester":{"email":"joe@bloggs.com","name":"Joe Blogg"},"subject":"ONLINE FORM - ","comment":{"body":"This is my query"},"custom_fields":[{"id":"360011490478","value":"contact_form"},{"id":"360011798678","value":"parent"},{"id":"360011519218","value":["hello","world"]},{"id":"360011762698","value":"0207 333 4444"},{"id":"360013507477","value":null}]}}',
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Basic Og==',
            'Content-Type' => 'application/json',
            'User-Agent' => 'ZendeskAPI Ruby 1.30.0',
          },
        )
        .to_return(status: 200, body: '', headers: {})

      service.send!
      expect(call_to_zendesk).to have_been_requested
    end
  end
end
