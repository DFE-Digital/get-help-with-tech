require 'rails_helper'

RSpec.describe SupportTicket::CheckYourRequestController, type: :controller do
  describe '#new' do
    before do
      session[:support_ticket] = { hello: 'world' }
      get :new
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'creates a form object' do
      expect(assigns(:form)).to be_instance_of(SupportTicket::CheckYourRequestForm)
    end

    it 'assigns the session data to a variable to play back all the details to the user' do
      expect(assigns(:support_ticket)).to eq({ hello: 'world' })
    end
  end

  describe '#save' do
    it 'clears the data in session state' do
      session[:support_ticket] = { hello: 'world' }
      post :save
      expect(session[:support_ticket]).to be_nil
    end

    it 'redirects to thank you page' do
      session[:support_ticket] = { hello: 'world' }
      post :save
      expect(response).to redirect_to(support_ticket_thank_you_path)
    end
  end
end
