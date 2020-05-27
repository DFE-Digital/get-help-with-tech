require 'rails_helper'

describe AllocationRequestForm do
  describe 'valid?' do
    let(:valid_user_params) {
      {
        full_name: 'John Smith',
        email_address: 'some@localauthority.gov.uk',
        organisation: 'some LA',
      }
    }
    let(:invalid_user_params) {
      {
        full_name: '',
        email_address: '2',
        organisation: '',
      }
    }

    let(:valid_allocation_request_params) {
      {
        number_eligible: 20,
        number_eligible_with_hotspot_access: 10
      }
    }
    let(:invalid_allocation_request_params) {
      {
        number_eligible: -2,
        number_eligible_with_hotspot_access: nil
      }
    }

    context 'with a valid user' do
      let(:args){ {user: User.new(valid_user_params), params: {}} }

      context 'and a valid allocation_request' do
        before do
          args[:allocation_request] = AllocationRequest.new(valid_allocation_request_params)
        end
        subject{ AllocationRequestForm.new(user: args[:user], allocation_request: args[:allocation_request], params: args[:params]) }

        it 'is true' do
          expect(subject.valid?).to be true
        end

        it 'sets no errors' do
          subject.valid?
          expect(subject.errors).to be_empty
        end
      end

      context 'and an invalid allocation_request' do
        before do
          subject.allocation_request = AllocationRequest.new(invalid_allocation_request_params)
        end

        it 'is false' do
          expect(subject.valid?).to be false
        end

        it 'sets an error' do
          subject.valid?
          expect(subject.errors).not_to be_empty
        end
      end
    end

    context 'with an invalid user' do
      let(:args){ {user: User.new(invalid_user_params), params: {}} }
      subject{ AllocationRequestForm.new(user: args[:user], allocation_request: args[:allocation_request], params: args[:params]) }

      it 'is false' do
        expect(subject.valid?).to be false
      end

      it 'sets an error' do
        subject.valid?
        expect(subject.errors).not_to be_empty
      end
    end

    context 'with valid params' do
      let(:params) {
        {
          user_name: 'jane doe',
          user_email: 'jane@example.com',
          user_organisation: 'some org',
          number_eligible: 20,
          number_eligible_with_hotspot_access: 12
        }
      }
      subject{ AllocationRequestForm.new(params: params) }

      it 'is valid' do
        expect(subject).to be_valid
      end

      it 'has no errors' do
        expect(subject.errors).to be_empty
      end
    end

    context 'with number_eligible < number_eligible_with_hotspot_access' do
      subject { AllocationRequestForm.new(params: {number_eligible: 12, number_eligible_with_hotspot_access: 20}) }

      it 'is not valid' do
        expect(subject).to_not be_valid
      end

      it 'has an error on the number_eligible_with_hotspot_access' do
        subject.valid?
        expect(subject.errors[:number_eligible_with_hotspot_access]).not_to be_empty
      end
    end
  end

end
