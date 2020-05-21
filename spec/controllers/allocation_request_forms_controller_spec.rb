require 'rails_helper'

describe AllocationRequestFormsController, type: :controller do
  describe '#create' do
    context 'with valid params' do
      let(:valid_params) {
        {
          user: {
            full_name: 'John Smith',
            email_address: 'john.smith@somelocalauthority.gov.uk',
            organisation: 'some local authority',
          },
          allocation_request: {
            number_eligible: 20,
            number_eligible_with_hotspot_access: 14
          },
        }
      }
      let(:params) { { allocation_request_form: valid_params } }
      let(:the_request) { post :create, params: params }

      context 'and no existing user in session' do
        let(:created_user) { User.last }

        before do
          session.delete(:user)
        end

        it 'creates a user' do
          expect{ the_request }.to change(User, :count).by(1)
        end

        describe 'the created user' do
          it 'has the right attributes' do
            the_request
            expect(created_user).to have_attributes(
              full_name: 'John Smith',
              email_address: 'john.smith@somelocalauthority.gov.uk',
              organisation: 'some local authority'
            )
          end
        end

        it 'sets the user_id in session' do
          expect{ the_request }.to change{session[:user_id]}
          expect(session[:user_id]).to eq(created_user.id)
        end
      end

      it 'creates an AllocationRequest' do
        expect{ the_request }.to change(AllocationRequest, :count).by(1)
      end

      describe 'the created AllocationRequest' do
        let(:created_allocation_request) { AllocationRequest.last }

        it 'has the right numbers' do
          the_request
          expect(created_allocation_request).to have_attributes(
            number_eligible: 20,
            number_eligible_with_hotspot_access: 14
          )
        end

        it 'is associated with the sessions user' do
          the_request
          expect(created_allocation_request.created_by_user_id).to eq(session[:user_id])
        end
      end
    end
  end
end
