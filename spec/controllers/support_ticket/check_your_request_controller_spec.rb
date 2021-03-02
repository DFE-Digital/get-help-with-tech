require 'rails_helper'

RSpec.describe SupportTicket::CheckYourRequestController, type: :controller do
  let(:support_ticket) { SupportTicket.create(session_id: session.id, user_type: 'other_type_of_user', full_name: 'My name') }

  describe '#new' do
    context 'when support ticket exists' do
      before do
        support_ticket
        get :new
      end

      it 'responds successfully' do
        expect(response).to be_successful
      end

      it 'creates a form object' do
        expect(assigns(:form)).to be_instance_of(SupportTicket::CheckYourRequestForm)
      end

      it 'assigns the persisted support ticket to a variable to play back all the details to the user' do
        expect(assigns(:support_ticket).full_name).to eq('My name')
      end

      it 'does not redirect to get support home page (using the wizard with existing data)' do
        expect(response).not_to redirect_to(support_ticket_path)
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
    describe 'when form is valid and ticket has been created' do
      it 'clears destroy the persisted support ticket' do
        support_ticket
        stubbed_form = SupportTicket::CheckYourRequestForm.new
        allow(stubbed_form).to receive(:valid?).and_return(true)
        allow(support_ticket).to receive(:submit_to_zendesk)
        controller.instance_variable_set(:@form, stubbed_form)
        expect {
          post :save
        }.to change(SupportTicket, :count).by(-1)
      end

      it 'stores the zendesk ticket number in session' do
        support_ticket
        stubbed_form = SupportTicket::CheckYourRequestForm.new
        allow(stubbed_form).to receive(:valid?).and_return(true)
        controller.instance_variable_set(:@form, stubbed_form)
        allow(Kernel).to receive(:rand).and_return(12_345)
        post :save
        expect(session[:support_ticket_number]).to be(12_345)
      end

      it 'redirects to thank you page' do
        stubbed_form = SupportTicket::CheckYourRequestForm.new
        allow(stubbed_form).to receive(:valid?).and_return(true)
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
        controller.instance_variable_set(:@form, stubbed_form)
        allow(Kernel).to receive(:rand).and_return(nil)
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
