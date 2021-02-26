require 'rails_helper'

RSpec.describe SupportTicket::ContactDetailsController, type: :controller do
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
        expect(assigns(:form)).to be_instance_of(SupportTicket::ContactDetailsForm)
      end

      it 'does not redirect to get support home page (using the wizard with existing data)' do
        expect(response).not_to redirect_to(support_ticket_path)
      end

      context 'when attempting to access the page when user is signed in' do
        let(:user) { create(:school_user) }

        before do
          allow(controller).to receive(:current_user).and_return(user)
          get :new
        end

        it 'sets user profile details in the support ticket' do
          support_ticket = SupportTicket.last

          expect(support_ticket.full_name).to eq(user.full_name)
          expect(support_ticket.email_address).to eq(user.email_address)
          expect(support_ticket.telephone_number).to eq(user.telephone)
          expect(support_ticket.user_profile_path).to eq(support_user_url(user.id))
        end

        it 'redirects the user to the next step' do
          expect(response).to redirect_to(support_ticket_support_needs_path)
        end
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
      post :save, params: { support_ticket_contact_details_form: { full_name: 'Joe Blogg', email_address: 'hello@world.com', telephone_number: '0203 333 3333' } }

      support_ticket = SupportTicket.last

      expect(support_ticket.full_name).to eq('Joe Blogg')
      expect(support_ticket.email_address).to eq('hello@world.com')
      expect(support_ticket.telephone_number).to eq('0203 333 3333')
      expect(support_ticket.user_profile_path).to be_nil
    end

    it 'redirects to support needs page' do
      post :save, params: { support_ticket_contact_details_form: { full_name: 'Joe Blogg', email_address: 'hello@world.com', telephone_number: '0203 333 3333' } }
      expect(response).to redirect_to(support_ticket_support_needs_path)
    end
  end
end
