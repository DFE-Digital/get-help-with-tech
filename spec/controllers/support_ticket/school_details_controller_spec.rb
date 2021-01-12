require 'rails_helper'

RSpec.describe SupportTicket::SchoolDetailsController, type: :controller do
  describe '#new' do
    before do
      session[:support_ticket] = { user_type: '' }
      get :new
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'creates a form object' do
      expect(assigns(:form)).to be_instance_of(SupportTicket::SchoolDetailsForm)
    end
  end

  describe '#save' do
    it 'stores the data in session state' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_school_details_form: { school_name: 'School 1', school_urn: '123456' } }
      expect(session[:support_ticket]).to eq({ school_name: 'School 1', school_urn: '123456', school_unique_id: '123456' })
    end

    it 'redirects to contact details page' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_school_details_form: { school_name: 'School 1', school_urn: '123456' } }
      expect(response).to redirect_to(support_ticket_contact_details_path)
    end
  end
end
