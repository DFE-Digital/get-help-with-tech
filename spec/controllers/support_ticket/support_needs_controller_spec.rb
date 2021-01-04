require 'rails_helper'

RSpec.describe SupportTicket::SupportNeedsController, type: :controller do
  describe '#new' do
    before do
      get :new
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'creates a form object' do
      expect(assigns(:form)).to be_instance_of(SupportTicket::SupportNeedsForm)
    end
  end

  describe '#save' do
    it 'stores the data in session state' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_support_needs_form: { support_topics: ['i_need_help', 'with the following'] } }
      expect(session[:support_ticket]).to eq({ support_topics: ['i_need_help', 'with the following'] })
    end

    it 'removes any empty options from the support topics' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_support_needs_form: { support_topics: ['', 'i_need_help', 'with the following'] } }
      expect(session[:support_ticket]).to eq({ support_topics: ['i_need_help', 'with the following'] })
    end

    it 'redirects to support details page' do
      session[:support_ticket] = {}
      post :save, params: { support_ticket_support_needs_form: { support_topics: ['i_need_help', 'with the following'] } }
      expect(response).to redirect_to(support_ticket_support_details_path)
    end
  end
end
