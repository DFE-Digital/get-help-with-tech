require 'rails_helper'

RSpec.describe SupportTicket::CollegeDetailsController, type: :controller do
  let(:support_ticket) { SupportTicket.create(session_id: session.id, user_type: 'other_type_of_user') }

  describe '#new' do
    context 'when support ticket exists' do
      before do
        support_ticket
        get :new
      end

      it 'responds successfully' do
        expect(response).to be_successful
      end

      it 'creates a form object' do
        expect(assigns(:form)).to be_instance_of(SupportTicket::CollegeDetailsForm)
      end

      it 'does not redirect to get support home page (using the wizard with existing data)' do
        expect(response).not_to redirect_to(support_ticket_path)
      end
    end

    describe 'when attempting to access the page directly without using the wizard' do
      before do
        get :new
      end

      it 'redirects to the get support home page' do
        expect(response).to redirect_to(support_ticket_path)
      end
    end
  end

  describe '#save' do
    it 'stores the data in support ticket' do
      post :save, params: { support_ticket_college_details_form: { college_name: 'College 1', college_ukprn: '12345678' } }

      support_ticket = SupportTicket.last

      expect(support_ticket.college_name).to eq('College 1')
      expect(support_ticket.college_ukprn).to eq('12345678')
      expect(support_ticket.school_name).to eq('College 1')
      expect(support_ticket.school_unique_id).to eq('12345678')
    end

    it 'redirects to contact details page' do
      post :save, params: { support_ticket_college_details_form: { college_name: 'College 1', college_ukprn: '12345678' } }
      expect(response).to redirect_to(support_ticket_contact_details_path)
    end
  end
end
