require 'rails_helper'

RSpec.describe AllocationJob do
  before do
    stub_computacenter_outgoing_api_calls(response_body: '', response_status: 200)
  end

  describe '#perform' do
    context 'when send_notification is false' do
      let!(:school) { create(:school) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order', send_notification: false) }

      it 'does not send notifications' do
        mock_service = instance_double(SchoolOrderStateAndCapUpdateService)
        allow(SchoolOrderStateAndCapUpdateService).to receive(:new).and_return(mock_service)
        allow(mock_service).to receive(:disable_user_notifications!)
        allow(mock_service).to receive(:call)

        described_class.perform_now(batch_job)

        expect(SchoolOrderStateAndCapUpdateService).to have_received(:new).with(
          school: school,
          order_state: batch_job.order_state,
          std_device_cap: batch_job.allocation_delta,
        )

        expect(mock_service).to have_received(:disable_user_notifications!)
      end

      it 'does not update sent_notification flag' do
        expect {
          described_class.perform_now(batch_job)
        }.not_to change { batch_job.reload.sent_notification }.from(false)
      end
    end

    context 'when send_notification is true' do
      let!(:school) { create(:school) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order', send_notification: true) }

      it 'sends notifications' do
        mock_service = instance_double(SchoolOrderStateAndCapUpdateService)
        allow(SchoolOrderStateAndCapUpdateService).to receive(:new).and_return(mock_service)
        allow(mock_service).to receive(:disable_user_notifications!)
        allow(mock_service).to receive(:call)

        described_class.perform_now(batch_job)

        expect(SchoolOrderStateAndCapUpdateService).to have_received(:new).with(
          school: school,
          order_state: batch_job.order_state,
          std_device_cap: batch_job.allocation_delta,
        )

        expect(mock_service).not_to have_received(:disable_user_notifications!)
      end

      it 'updates sent_notification flag' do
        expect {
          described_class.perform_now(batch_job)
        }.to change { batch_job.reload.sent_notification }.from(false).to(true)
      end
    end

    context 'school does not have an allocation' do
      let!(:school) { create(:school) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order') }

      it 'creates and sets the allocation' do
        described_class.perform_now(batch_job)

        expect(school.std_device_allocation.allocation).to be(3)
      end

      it 'creates and sets the cap' do
        described_class.perform_now(batch_job)

        expect(school.std_device_allocation.cap).to be(3)
      end
    end

    context 'for school that cannot order' do
      let!(:school) { create(:school, :with_std_device_allocation) }

      context 'updating to can_order' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order') }

        it 'updates the allocation' do
          expect {
            described_class.perform_now(batch_job)
          }.to change { school.std_device_allocation.reload.allocation }.by(3)
        end

        it 'updates the cap to match allocation' do
          described_class.perform_now(batch_job)

          expect(school.std_device_allocation.reload.cap).to eql(school.std_device_allocation.reload.allocation)
        end

        it 'marks job as processed' do
          described_class.perform_now(batch_job)

          expect(batch_job.reload).to be_processed
        end
      end

      context 'maintaining cannot_order' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'cannot_order') }

        it 'updates the allocation' do
          expect {
            described_class.perform_now(batch_job)
          }.to change { school.std_device_allocation.reload.allocation }.by(3)
        end

        it 'leaves the cap as is' do
          expect {
            described_class.perform_now(batch_job)
          }.not_to(change { school.std_device_allocation.reload.cap })
        end

        it 'marks job as processed' do
          described_class.perform_now(batch_job)

          expect(batch_job.reload).to be_processed
        end
      end

      context 'reducing allocation' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'cannot_order') }

        it 'reduces allocation' do
          expect {
            described_class.perform_now(batch_job)
          }.to change { school.std_device_allocation.reload.allocation }.by(-1)
        end
      end
    end

    context 'for school that can order' do
      let(:school) { create(:school, :with_std_device_allocation, :in_lockdown) }

      context 'maintaining can_order' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order') }

        it 'updates the allocation' do
          expect {
            described_class.perform_now(batch_job)
          }.to change { school.std_device_allocation.reload.allocation }.by(3)
        end

        it 'updates the cap to match allocation' do
          described_class.perform_now(batch_job)

          expect(school.std_device_allocation.reload.cap).to eql(school.std_device_allocation.reload.allocation)
        end

        it 'marks job as processed' do
          described_class.perform_now(batch_job)

          expect(batch_job.reload).to be_processed
        end
      end

      context 'updating to cannot_order' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'cannot_order') }

        it 'updates the allocation' do
          expect {
            described_class.perform_now(batch_job)
          }.to change { school.std_device_allocation.reload.allocation }.by(3)
        end

        it 'zeros the cap' do
          described_class.perform_now(batch_job)

          expect(school.std_device_allocation.reload.cap).to be(0)
        end

        it 'marks job as processed' do
          described_class.perform_now(batch_job)

          expect(batch_job.reload).to be_processed
        end
      end

      context 'reducing allocation' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'cannot_order') }

        it 'reduces allocation' do
          expect {
            described_class.perform_now(batch_job)
          }.to change { school.std_device_allocation.reload.allocation }.by(-1)
        end
      end
    end

    context 'when school is part of virtual cap pool' do
      let(:batch_job) { create(:allocation_batch_job, urn: school1.urn, allocation_delta: '3', order_state: 'can_order') }

      let(:rb) do
        create(:trust,
               :manages_centrally,
               :vcap_feature_flag)
      end

      let(:school1) { rb.schools.first }
      let(:school2) { rb.schools.last }

      before do
        create_list(:school, 2,
                    :centrally_managed,
                    responsible_body: rb)

        create(:school_device_allocation, :with_std_allocation, :with_orderable_devices, school: school1)
        create(:school_device_allocation, :with_std_allocation, :with_orderable_devices, school: school2)

        rb.add_school_to_virtual_cap_pools!(school1)
        rb.add_school_to_virtual_cap_pools!(school2)

        batch_job
      end

      it 'updates the allocation' do
        expect {
          described_class.perform_now(batch_job)
        }.to change { school1.std_device_allocation.reload.raw_allocation }.by(3)
      end

      it 'updates the cap to match allocation' do
        described_class.perform_now(batch_job)

        sum = school1.std_device_allocation.reload.raw_cap + school2.std_device_allocation.reload.raw_cap
        expect(school1.std_device_allocation.cap).to eql(sum)
        expect(school2.std_device_allocation.cap).to eql(sum)

        expect(school1.std_device_allocation.raw_cap).to eql(school1.std_device_allocation.raw_allocation)
      end

      context 'reducing allocation' do
        let(:batch_job) { create(:allocation_batch_job, urn: school1.urn, allocation_delta: '-1', order_state: 'can_order') }

        it 'reduces allocation' do
          expect {
            described_class.perform_now(batch_job)
          }.to change { school1.std_device_allocation.reload.raw_allocation }.by(-1)
        end
      end
    end
  end
end
