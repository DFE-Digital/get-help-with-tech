require 'rails_helper'

describe AllocationRequestForm do
  describe 'valid?' do
    let(:valid_user_params) do
      {
        full_name: 'John Smith',
        email_address: 'some@localauthority.gov.uk',
        organisation: 'some LA',
      }
    end
    let(:invalid_user_params) do
      {
        full_name: '',
        email_address: '2',
        organisation: '',
      }
    end
    let(:valid_allocation_request_params) do
      {
        number_eligible: 20,
        number_eligible_with_hotspot_access: 10,
      }
    end
    let(:invalid_allocation_request_params) do
      {
        number_eligible: -2,
        number_eligible_with_hotspot_access: nil,
      }
    end

    context 'with a valid user and a valid allocation_request' do
      let(:args) { { user: User.new(valid_user_params), params: {} } }
      let(:form) { AllocationRequestForm.new(user: args[:user], allocation_request: args[:allocation_request], params: args[:params]) }

      before do
        args[:allocation_request] = AllocationRequest.new(valid_allocation_request_params)
      end

      it 'is true' do
        expect(form.valid?).to be true
      end

      it 'sets no errors' do
        form.valid?
        expect(form.errors).to be_empty
      end
    end

    context 'with a valid user and an invalid allocation_request' do
      let(:args) { { user: User.new(valid_user_params), params: {} } }
      let(:form) { AllocationRequestForm.new(allocation_request: AllocationRequest.new(invalid_allocation_request_params)) }

      it 'is false' do
        expect(form.valid?).to be false
      end

      it 'sets an error' do
        form.valid?
        expect(form.errors).not_to be_empty
      end
    end

    context 'with an invalid user' do
      let(:args) { { user: User.new(invalid_user_params), params: {} } }
      let(:form) { AllocationRequestForm.new(user: args[:user], allocation_request: args[:allocation_request], params: args[:params]) }

      it 'is false' do
        expect(form.valid?).to be false
      end

      it 'sets an error' do
        form.valid?
        expect(form.errors).not_to be_empty
      end
    end

    context 'with valid params' do
      let(:params) do
        {
          user_name: 'jane doe',
          user_email: 'jane@example.com',
          user_organisation: 'some org',
          number_eligible: 20,
          number_eligible_with_hotspot_access: 12,
        }
      end

      let(:form) { AllocationRequestForm.new(params: params) }

      it 'is valid' do
        expect(form).to be_valid
      end

      it 'has no errors' do
        expect(form.errors).to be_empty
      end
    end

    context 'with number_eligible < number_eligible_with_hotspot_access' do
      let(:form) { AllocationRequestForm.new(params: { number_eligible: 12, number_eligible_with_hotspot_access: 20 }) }

      it 'is not valid' do
        expect(form).not_to be_valid
      end

      it 'has an error on the number_eligible_with_hotspot_access' do
        form.valid?
        expect(form.errors[:number_eligible_with_hotspot_access]).not_to be_empty
      end
    end
  end
end
