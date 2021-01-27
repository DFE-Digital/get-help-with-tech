require 'rails_helper'

RSpec.describe SupportTicket::CheckYourRequestController, type: :controller do
  describe '#new' do
    before do
      session[:support_ticket] = { full_name: 'My name' }
      get :new
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'creates a form object' do
      expect(assigns(:form)).to be_instance_of(SupportTicket::CheckYourRequestForm)
    end

    it 'assigns the session data to a variable to play back all the details to the user' do
      expect(assigns(:support_ticket).full_name).to eq('My name')
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
    describe 'when form is valid and ticket has been created' do
      it 'clears the data in session state' do
        stubbed_form = SupportTicket::CheckYourRequestForm.new
        allow(stubbed_form).to receive(:valid?).and_return(true)
        allow(stubbed_form).to receive(:create_ticket).and_return(12_345)
        allow(stubbed_form).to receive(:ticket_number).and_return(12_345)
        controller.instance_variable_set(:@form, stubbed_form)
        session[:support_ticket] = { hello: 'world' }
        post :save
        expect(session[:support_ticket]).to be_nil
      end

      it 'stores the zendesk ticket number in session' do
        stubbed_form = SupportTicket::CheckYourRequestForm.new
        allow(stubbed_form).to receive(:valid?).and_return(true)
        allow(stubbed_form).to receive(:create_ticket).and_return(12_345)
        allow(stubbed_form).to receive(:ticket_number).and_return(12_345)
        controller.instance_variable_set(:@form, stubbed_form)
        post :save
        expect(session[:support_ticket_number]).to eq(12_345)
      end

      it 'redirects to thank you page' do
        stubbed_form = SupportTicket::CheckYourRequestForm.new
        allow(stubbed_form).to receive(:valid?).and_return(true)
        allow(stubbed_form).to receive(:create_ticket).and_return(12_345)
        allow(stubbed_form).to receive(:ticket_number).and_return(12_345)
        controller.instance_variable_set(:@form, stubbed_form)
        post :save
        expect(response).to redirect_to(support_ticket_thank_you_path)
      end
    end

    describe 'when form is invalid' do
      it 'sets a flash message' do
        stubbed_form = SupportTicket::CheckYourRequestForm.new
        allow(stubbed_form).to receive(:valid?).and_return(false)
        controller.instance_variable_set(:@form, stubbed_form)
        post :save
        expect(flash[:warning]).to be_present
      end

      it 'renders the check your request partial again' do
        stubbed_form = SupportTicket::CheckYourRequestForm.new
        allow(stubbed_form).to receive(:valid?).and_return(false)
        controller.instance_variable_set(:@form, stubbed_form)
        expect(post(:save)).to render_template('support_tickets/check_your_request')
      end
    end

    describe 'when create_ticket fails' do
      it 'sets a flash message' do
        stubbed_form = SupportTicket::CheckYourRequestForm.new
        allow(stubbed_form).to receive(:valid?).and_return(true)
        allow(stubbed_form).to receive(:create_ticket).and_return(nil)
        controller.instance_variable_set(:@form, stubbed_form)
        post :save
        expect(flash[:warning]).to be_present
      end

      it 'renders the check your request partial again' do
        stubbed_form = SupportTicket::CheckYourRequestForm.new
        allow(stubbed_form).to receive(:valid?).and_return(false)
        controller.instance_variable_set(:@form, stubbed_form)
        expect(post(:save)).to render_template('support_tickets/check_your_request')
      end
    end
  end
end
