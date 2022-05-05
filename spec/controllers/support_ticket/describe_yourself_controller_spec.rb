require 'rails_helper'

RSpec.describe SupportTicket::DescribeYourselfController, type: :controller do
  describe '#new' do
    before do
      get :new
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'creates a form object' do
      expect(assigns(:form)).to be_instance_of(SupportTicket::DescribeYourselfForm)
    end

    it 'does not redirect to get support home page because its the first page in the wizard' do
      expect(response).not_to redirect_to(support_ticket_path)
    end

    describe 'when attempting to access the page directly without using the wizard' do
      before do
        get :new
      end

      it 'does not redirect to the get support home page' do
        expect(response).not_to redirect_to(support_ticket_path)
      end
    end
  end

  describe '#save' do
    it 'stores the selected user type in support ticket' do
      post :save, params: { support_ticket_describe_yourself_form: { user_type: 'local_authority' } }
      support_ticket = SupportTicket.find_by(session_id: session.id.to_s)
      expect(support_ticket.user_type).to eq('local_authority')
    end

    it 'redirects to academy details page' do
      post :save, params: { support_ticket_describe_yourself_form: { user_type: 'multi_academy_trust' } }
      expect(response).to redirect_to(support_ticket_academy_details_path)
    end

    it 'redirects to LA details page' do
      post :save, params: { support_ticket_describe_yourself_form: { user_type: 'local_authority' } }
      expect(response).to redirect_to(support_ticket_local_authority_details_path)
    end

    it 'redirects to college details page' do
      post :save, params: { support_ticket_describe_yourself_form: { user_type: 'college' } }
      expect(response).to redirect_to(support_ticket_college_details_path)
    end

    it 'redirects to parents info page' do
      post :save, params: { support_ticket_describe_yourself_form: { user_type: 'parent_or_guardian_or_carer_or_pupil_or_care_leaver' } }
      expect(response).to redirect_to(support_ticket_parent_support_path)
    end

    it 'redirects to contact details page for other types of users' do
      post :save, params: { support_ticket_describe_yourself_form: { user_type: 'other_type_of_user' } }
      expect(response).to redirect_to(support_ticket_contact_details_path)
    end

    it 'redirects back to the form for invalid type of user' do
      post :save, params: { support_ticket_describe_yourself_form: { user_type: 'wrong' } }
      expect(response).to render_template('support_tickets/describe_yourself')
    end
  end
end
