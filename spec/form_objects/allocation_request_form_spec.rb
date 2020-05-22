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
      before do
        subject.user = User.new(valid_user_params)
      end

      context 'and a valid allocation_request' do
        before do
          subject.allocation_request = AllocationRequest.new(valid_allocation_request_params)
        end

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

        it 'sets an error on the allocation_request' do
          subject.valid?
          expect(subject.errors[:allocation_request]).not_to be_empty
        end
      end
    end

    context 'with an invalid user' do
      before do
        subject.user = User.new(invalid_user_params)
      end

      it 'is false' do
        expect(subject.valid?).to be false
      end

      it 'sets an error on the user' do
        subject.valid?
        expect(subject.errors[:user]).not_to be_empty
      end
    end
  end
end
