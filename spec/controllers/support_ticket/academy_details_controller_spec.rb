require 'rails_helper'

RSpec.describe SupportTicket::AcademyDetailsController, type: :controller do
  describe '#new' do
    before do
      get :new
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'creates a form object' do
      expect(assigns(:form)).to be_instance_of(SupportTicket::AcademyDetailsForm)
    end
  end

  describe '#save' do
    it 'stores the data in session state' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_academy_details_form: { academy_name: 'Academy 1' } }
      expect(session[:support_ticket]).to eq({ academy_name: 'Academy 1', school_name: 'Academy 1', school_unique_id: '' })
    end

    it 'redirects to contact details page' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_academy_details_form: { academy_name: 'Academy 1' } }
      expect(response).to redirect_to(support_ticket_contact_details_path)
    end
  end
end
