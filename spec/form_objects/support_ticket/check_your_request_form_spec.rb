require 'rails_helper'

RSpec.describe SupportTicket::CheckYourRequestForm do
  let(:mock_ticket) do
    {
      'full_name' => 'Joe Blogg',
      'email_address' => 'joe@bloggs.com',
      'user_type' => 'parent',
      'telephone_number' => '0207 333 4444',
      'subject' => 'My query',
      'message' => 'This is my query',
      'support_topics' => %w[hello world],
    }
  end

  describe 'when zendesk credentials are provided' do
    before do
      allow(Settings.zendesk).to receive(:username).and_return('Test User')
      allow(Settings.zendesk).to receive(:token).and_return('123456')
    end

    it 'calls the zendesk service to create a ticket in zendesk' do
      allow(ZendeskService).to receive(:send!)
      described_class.new(ticket: mock_ticket).create_ticket
      expect(ZendeskService).to have_received(:send!)
    end

    context 'Subject' do
      it 'sets the email subject line to include just school name' do
        allow(ZendeskService).to receive(:send!)
        described_class.new(ticket: { 'school_name' => 'School 1' }).create_ticket
        expect(ZendeskService).to have_received(:send!)
                                    .with({ 'school_name' => 'School 1',
                                            'subject' => 'ONLINE FORM - School 1' })
      end

      it 'sets the email subject line include name and URN/UKPRN' do
        allow(ZendeskService).to receive(:send!)
        described_class.new(ticket: { 'school_name' => 'School 1', 'school_unique_id' => '123456' }).create_ticket
        expect(ZendeskService).to have_received(:send!)
                                    .with({
                                      'school_name' => 'School 1',
                                      'school_unique_id' => '123456',
                                      'subject' => 'ONLINE FORM - (123456) School 1',
                                    })
      end
    end
  end

  describe 'when zendesk credentials are not provided' do
    it 'does not call zendesk service' do
      allow(ZendeskService).to receive(:send!)
      described_class.new(ticket: mock_ticket).create_ticket
      expect(ZendeskService).not_to have_received(:send!)
    end
  end
end
