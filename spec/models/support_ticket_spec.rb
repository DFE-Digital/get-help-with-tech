require 'rails_helper'

RSpec.describe SupportTicket do
  subject(:support_ticket) { SupportTicket.new }

  it 'has sensible defaults' do
    expect(support_ticket.user_type).to be_nil
    expect(support_ticket.school_name).to be_nil
    expect(support_ticket.school_unique_id).to be_nil
    expect(support_ticket.full_name).to be_nil
    expect(support_ticket.email_address).to be_nil
    expect(support_ticket.telephone_number).to be_nil
    expect(support_ticket.support_topics).to eq []
    expect(support_ticket.message).to be_nil
  end

  describe '#requires_school?' do
    it 'returns true for applicable user types' do
      %w[school_or_single_academy_trust multi_academy_trust local_authority college].each do |user_type|
        expect(described_class.new(user_type:).requires_school?).to eq true
      end
    end

    it 'returns false for types that do not require school details' do
      %w[other_type_of_user parent_or_guardian_or_carer_or_pupil_or_care_leaver].each do |user_type|
        expect(described_class.new(user_type:).requires_school?).to eq false
      end
    end
  end

  describe '#submit_to_zendesk' do
    subject(:mock_ticket) do
      described_class.new(
        full_name: 'Joe Blogg',
        email_address: 'joe@bloggs.com',
        user_type: 'parent',
        telephone_number: '0207 333 4444',
        message: 'This is my query',
        support_topics: %w[hello world],
      )
    end

    describe 'when zendesk credentials are provided' do
      before do
        allow(Settings.zendesk).to receive(:username).and_return('Test User')
        allow(Settings.zendesk).to receive(:token).and_return('123456')
      end

      it 'calls the zendesk service to create a ticket in zendesk' do
        allow(ZendeskService).to receive(:send!).and_return(instance_double('ZendeskAPI::Request', id: 56_789))
        mock_ticket.submit_to_zendesk
        expect(ZendeskService).to have_received(:send!)
      end

      it 'sets ticket_number instance variable' do
        allow(ZendeskService).to receive(:send!).and_return(nil)
        allow(ZendeskService).to receive(:send!).and_return(instance_double('ZendeskAPI::Request', id: 56_789))
        mock_ticket.submit_to_zendesk
        expect(mock_ticket.ticket_number).to eq(56_789)
      end

      it 'returns ticket_number created in zendesk' do
        allow(ZendeskService).to receive(:send!).and_return(instance_double('ZendeskAPI::Request', id: 15_264))
        mock_ticket.submit_to_zendesk
        expect(mock_ticket.ticket_number).to eq(15_264)
      end

      describe 'when ZendeskService fails' do
        # ZendeskAPI::Request.create! should return nil if there are any errors while trying to create zendesk ticket
        it 'sets ticket_number instance variable to nil' do
          allow(ZendeskService).to receive(:send!).and_return(instance_double('ZendeskAPI::Request', id: nil))
          mock_ticket.submit_to_zendesk
          expect(mock_ticket.ticket_number).to be_nil
        end

        it 'returns nil' do
          allow(ZendeskService).to receive(:send!).and_return(nil)
          mock_ticket.submit_to_zendesk
          expect(mock_ticket.ticket_number).to be_nil
        end
      end
    end

    describe 'when zendesk credentials are not provided' do
      it 'does not call zendesk service' do
        allow(ZendeskService).to receive(:send!)
        mock_ticket.submit_to_zendesk
        expect(ZendeskService).not_to have_received(:send!)
      end

      it 'sets ticket_number instance variable to a random 5 digit  number' do
        mock_ticket.submit_to_zendesk
        expect(mock_ticket.ticket_number).to be_between(10_000, 99_999)
      end

      it 'returns a random 5 digit number' do
        ticket_number = mock_ticket.submit_to_zendesk
        expect(ticket_number).to be_between(10_000, 99_999)
      end
    end
  end
end
