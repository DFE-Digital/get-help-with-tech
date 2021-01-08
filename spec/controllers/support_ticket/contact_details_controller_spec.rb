require 'rails_helper'

RSpec.describe SupportTicket::ContactDetailsController, type: :controller do
  describe '#new' do
    before do
      get :new
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'creates a form object' do
      expect(assigns(:form)).to be_instance_of(SupportTicket::ContactDetailsForm)
    end
  end

  describe '#save' do
    it 'stores the data in session state' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_contact_details_form: { full_name: 'Joe Blogg', email_address: 'hello@world.com', telephone_number: '0203 333 3333' } }
      expect(session[:support_ticket]).to eq({ full_name: 'Joe Blogg', email_address: 'hello@world.com', telephone_number: '0203 333 3333' })
    end

    it 'redirects to support needs page' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_contact_details_form: { full_name: 'Joe Blogg', email_address: 'hello@world.com', telephone_number: '0203 333 3333' } }
      expect(response).to redirect_to(support_ticket_support_needs_path)
    end
  end
end
