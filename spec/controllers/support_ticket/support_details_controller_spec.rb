require 'rails_helper'

RSpec.describe SupportTicket::SupportDetailsController, type: :controller do
  describe '#new' do
    before do
      session[:support_ticket] = { user_type: '' }
      get :new
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'creates a form object' do
      expect(assigns(:form)).to be_instance_of(SupportTicket::SupportDetailsForm)
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
  end

  describe '#save' do
    it 'stores the data in session state' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_support_details_form: { message: 'please help me with this issue' } }
      expect(session[:support_ticket]).to eq({ message: 'please help me with this issue' })
    end

    it 'redirects to check your answers page' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_support_details_form: { message: 'please help me with this issue' } }
      expect(response).to redirect_to(support_ticket_check_your_request_path)
    end
  end
end
