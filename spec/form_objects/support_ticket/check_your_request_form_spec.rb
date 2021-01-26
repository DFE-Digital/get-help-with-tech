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

    describe '#create_ticket' do
      it 'calls the zendesk service to create a ticket in zendesk' do
        allow(ZendeskService).to receive(:send!).and_return( double ZendeskAPI::Request, id: 56789)
        described_class.new(ticket: mock_ticket).create_ticket
        expect(ZendeskService).to have_received(:send!)
      end

      it 'sets ticket_number instance variable' do
        allow(ZendeskService).to receive(:send!).and_return(instance_double('ZendeskAPI::Request', id: 56_789))
        form_object = described_class.new(ticket: mock_ticket)
        form_object.create_ticket
        expect(form_object.ticket_number).to eq(56_789)
      end

      it 'returns ticket_number created in zendesk' do
        allow(ZendeskService).to receive(:send!).and_return(instance_double('ZendeskAPI::Request', id: 15_264))
        form_object = described_class.new(ticket: mock_ticket)
        expect(form_object.create_ticket).to eq(15_264)
      end

      describe 'when ZendeskService fails' do
        # ZendeskAPI::Request.create! should return nil if there are any errors while trying to create zendesk ticket
        it 'sets ticket_number instance variable to nil' do
          allow(ZendeskService).to receive(:send!).and_return(nil)
          form_object = described_class.new(ticket: mock_ticket)
          form_object.create_ticket
          expect(form_object.ticket_number).to be_nil
        end

        it 'returns nil' do
          allow(ZendeskService).to receive(:send!).and_return(nil)
          form_object = described_class.new(ticket: mock_ticket)
          expect(form_object.create_ticket).to be_nil
        end
      end
    end



    context 'Subject' do
      it 'sets the email subject line to include just school name' do
        allow(ZendeskService).to receive(:send!)
        form_object = described_class.new(ticket: { 'school_name' => 'School 1' })
        form_object.create_ticket
        expect(ZendeskService).to have_received(:send!)
                                    .with({ 'school_name' => 'School 1',
                                            'subject' => 'ONLINE FORM - School 1' })
      end

      it 'set the email subject line to say "Other" if its not from school,LA,college, academy' do
        allow(ZendeskService).to receive(:send!)
        described_class.new(ticket: { 'user_type' => 'other_type_of_user' }).create_ticket
        expect(ZendeskService).to have_received(:send!)
                                    .with({ 'subject' => 'ONLINE FORM - Other',
                                            'user_type' => 'other_type_of_user' })
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


    it 'sets ticket_number instance variable to a random 5 digit  number' do
      form_object = described_class.new(ticket: mock_ticket)
      form_object.create_ticket
      expect(form_object.ticket_number).to be_between(10_000, 99_999)
    end

    it 'returns a random 5 digit number' do
      ticket_number = described_class.new(ticket: mock_ticket).create_ticket
      expect(ticket_number).to be_between(10000,99999)
    end
  end
end
