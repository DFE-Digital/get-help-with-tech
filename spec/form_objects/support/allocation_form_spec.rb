require 'rails_helper'

RSpec.describe Support::AllocationForm do
  describe 'validations' do
    context 'when in a virtual cap pool' do
      let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }
      let :school do
        create(:school, :centrally_managed, :in_lockdown, responsible_body: responsible_body)
      end
      let! :school_device_allocation do
        create(:school_device_allocation, school: school, allocation: initial_value)
      end

      subject :form do
        described_class.new(allocation: updated_value, school_allocation: school_device_allocation)
      end

      before do
        # Properly associate things with a virtual cap pool.
        responsible_body.add_school_to_virtual_cap_pools!(school)
        school_device_allocation.reload
      end

      # Precondition
      context 'precondition' do
        let(:initial_value) { 1 }
        let(:updated_value) { 2 }

        it 'school_device_allocation#is_in_virtual_cap_pool? is true' do
          expect(school_device_allocation.is_in_virtual_cap_pool?).to be true
        end
      end

      context 'when increasing the allocation' do
        let(:initial_value) { 1 }
        let(:updated_value) { 2 }

        it 'is valid' do
          expect(form).to be_valid
        end
      end

      context 'when decreasing the allocation' do
        let(:initial_value) { 2 }
        let(:updated_value) { 1 }

        it 'has errors' do
          expect(form).to be_invalid
          expect(form.errors[:allocation]).to be_present
          expect(form.errors[:allocation].first).to include('Decreasing an allocation for a school in a virtual cap pool is currently not possible')
        end
      end
    end

    context 'compared with raw_devices_ordered' do
      let(:school_device_allocation) { create(:school_device_allocation, allocation: 3, devices_ordered: 2) }

      context 'when allocation is above raw_devices_ordered' do
        subject(:form) { described_class.new(allocation: 4, school_allocation: school_device_allocation) }

        it 'is valid' do
          expect(form).to be_valid
        end
      end

      context 'when allocation is below raw_devices_ordered' do
        subject(:form) { described_class.new(allocation: 1, school_allocation: school_device_allocation) }

        it 'has errors' do
          expect(form).to be_invalid
          expect(form.errors[:allocation]).to be_present
          expect(form.errors[:allocation].first).to include('Allocation cannot be less than the number they have already ordered')
        end
      end
    end
  end
end
