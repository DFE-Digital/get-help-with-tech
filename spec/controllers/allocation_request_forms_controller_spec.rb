require 'rails_helper'

describe AllocationRequestFormsController, type: :controller do
  def sign_in_as(user)
    # TestSession doesn't do this automatically like a real session
    session[:session_id] = SecureRandom.uuid
    controller.send(:save_user_to_session!, user)
  end

  describe '#create' do
    let(:invalid_params) do
      {
        number_eligible: -2,
      }
    end
    let(:valid_params) do
      {
        number_eligible: 20,
        number_eligible_with_hotspot_access: 14,
      }
    end
    let(:params) { { allocation_request_form: valid_params } }
    let(:created_allocation_request) { AllocationRequest.last }
    let(:the_request) { post :create, params: params }

    context 'with valid params and no existing user in session' do
      before do
        session.delete(:user)
        # TestSession doesn't create this automatically like a real session
        session[:session_id] = SecureRandom.uuid
      end

      it 'redirects to sign_in' do
        the_request
        expect(response).to redirect_to(sign_in_path)
      end

      it 'does not change the user_id in session' do
        expect { the_request }.not_to(change { session[:user_id] })
        expect(session[:user_id]).to be_nil
      end

      it 'does not create an AllocationRequest' do
        expect { the_request }.not_to change(AllocationRequest, :count)
      end
    end

    context 'with valid params and an existing user in session' do
      let(:user) { create(:local_authority_user) }

      before do
        sign_in_as user
      end

      it 'creates an AllocationRequest with the right numbers' do
        the_request
        expect(created_allocation_request).to have_attributes(
          number_eligible: 20,
          number_eligible_with_hotspot_access: 14,
        )
      end

      it 'creates an AllocationRequest associated with the sessions user' do
        the_request
        expect(created_allocation_request.created_by_user_id).to eq(session[:user_id])
      end
    end

    context 'with invalid params and an existing user in session' do
      let(:user) { create(:local_authority_user) }
      let(:params) { { allocation_request_form: invalid_params } }
      let(:the_request) { post :create, params: params }

      before do
        sign_in_as user
      end

      it 'does not create an AllocationRequest' do
        expect { post :create, params: params }.not_to change(AllocationRequest, :count)
      end

      it 'responds with a 400 status code' do
        post :create, params: params
        expect(response.status).to eq(400)
      end
    end
  end
end
