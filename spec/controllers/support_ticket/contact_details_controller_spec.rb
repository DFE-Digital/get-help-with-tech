require 'rails_helper'

RSpec.describe SupportTicket::ContactDetailsController, type: :controller do
  describe '#new' do
    before do
      session[:support_ticket] = { user_type: '' }
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

    describe 'when attempting to access the page directly without using the wizard' do
      before do
        session[:support_ticket] = nil
        get :new
      end

      it 'redirects to the get support home page' do
        expect(response).to redirect_to(support_ticket_path)
      end
    end

    context 'when attempting to access the page when user is signed in' do
      let(:user) { create(:school_user) }

      before do
        session[:support_ticket] = { user_type: '' }
        allow(controller).to receive(:current_user).and_return(user)
        get :new
      end

      it 'sets user profile details in the session' do
        expect(session[:support_ticket][:full_name]).to eq(user.full_name)
        expect(session[:support_ticket][:email_address]).to eq(user.email_address)
        expect(session[:support_ticket][:telephone_number]).to eq(user.telephone)
        expect(session[:support_ticket][:user_profile_path]).to eq(support_user_url(user.id))
      end

      it 'redirects the user to the next step' do
        expect(response).to redirect_to(support_ticket_support_needs_path)
      end
    end
  end

  describe '#save' do
    it 'stores the data in session state' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_contact_details_form: { full_name: 'Joe Blogg', email_address: 'hello@world.com', telephone_number: '0203 333 3333' } }
      expect(session[:support_ticket]).to eq({ full_name: 'Joe Blogg', email_address: 'hello@world.com', telephone_number: '0203 333 3333', user_profile_path: nil })
    end

    it 'redirects to support needs page' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_contact_details_form: { full_name: 'Joe Blogg', email_address: 'hello@world.com', telephone_number: '0203 333 3333' } }
      expect(response).to redirect_to(support_ticket_support_needs_path)
    end
  end
end
