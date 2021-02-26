require 'rails_helper'

RSpec.describe SupportTicket::LocalAuthorityDetailsController, type: :controller do
  let(:support_ticket) { SupportTicket.create(session_id: session.id, user_type: 'other_type_of_user') }

  describe '#new' do
    context 'with existing support ticket' do
      before do
        support_ticket
        get :new
      end

      it 'responds successfully' do
        expect(response).to be_successful
      end

      it 'creates a form object' do
        expect(assigns(:form)).to be_instance_of(SupportTicket::LocalAuthorityDetailsForm)
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
    it 'stores the data in the database' do
      post :save, params: { support_ticket_local_authority_details_form: { local_authority_name: 'LA 1' } }

      support_ticket = SupportTicket.last

      expect(support_ticket.local_authority_name).to eq('LA 1')
      expect(support_ticket.school_name).to eq('LA 1')
      expect(support_ticket.school_unique_id).to eq('')
    end

    it 'redirects to contact details page' do
      post :save, params: { support_ticket_local_authority_details_form: { local_authority_name: 'LA 1' } }
      expect(response).to redirect_to(support_ticket_contact_details_path)
    end
  end
end
