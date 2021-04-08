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

          expect(batch_job.reload.processed?).to be_truthy
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

          expect(batch_job.reload.processed?).to be_truthy
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

          expect(batch_job.reload.processed?).to be_truthy
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

          expect(batch_job.reload.processed?).to be_truthy
        end
      end
    end
  end
end
