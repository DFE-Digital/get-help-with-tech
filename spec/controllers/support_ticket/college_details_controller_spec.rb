require 'rails_helper'

RSpec.describe SupportTicket::CollegeDetailsController, type: :controller do
  describe '#new' do
    before do
      get :new
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'creates a form object' do
      expect(assigns(:form)).to be_instance_of(SupportTicket::CollegeDetailsForm)
    end
  end

  describe '#save' do
    it 'stores the data in session state' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_college_details_form: { college_name: 'College 1', college_ukprn: '123456' } }
      expect(session[:support_ticket]).to eq({ college_name: 'College 1', college_ukprn: '123456', school_name: 'College 1', school_unique_id: '123456' })
    end

    it 'redirects to contact details page' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_college_details_form: { college_name: 'College 1', college_ukprn: '123456' } }
      expect(response).to redirect_to(support_ticket_contact_details_path)
    end
  end
end
