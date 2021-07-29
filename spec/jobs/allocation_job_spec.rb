require 'rails_helper'

RSpec.describe AllocationJob do
  before do
    stub_computacenter_outgoing_api_calls(response_body: '', response_status: 200)
  end

  describe '#perform' do
    describe 'idempotency' do
      context 'unprocessed' do
        let!(:school) { create(:school, :with_std_device_allocation) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: 'can_order') }

        it 'only updates the first time' do
          expect { described_class.perform_now([batch_job]) }.to change { school.std_device_allocation.reload.allocation }.by(1)
          expect { described_class.perform_now([batch_job]) }.not_to change { school.std_device_allocation.reload.allocation } # rubocop:disable Lint/AmbiguousBlockAssociation
        end
      end

      context 'already processed' do
        let!(:school) { create(:school, :with_std_device_allocation) }
        let(:batch_job) { create(:allocation_batch_job, processed: true, urn: school.urn, allocation_delta: 1, order_state: 'can_order') }

        specify { expect { described_class.perform_now([batch_job]) }.not_to change { school.std_device_allocation.reload.allocation } } # rubocop:disable Lint/AmbiguousBlockAssociation
      end
    end

    context 'when send_notification is false' do
      let!(:school) { create(:school) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order') }

      it 'does not send notifications' do
        mock_service = instance_double(SchoolOrderStateAndCapUpdateService)
        allow(SchoolOrderStateAndCapUpdateService).to receive(:new).and_return(mock_service)
        allow(mock_service).to receive(:disable_user_notifications!)
        allow(mock_service).to receive(:call)

        described_class.perform_now([batch_job], send_notifications: false)

        expect(SchoolOrderStateAndCapUpdateService).to have_received(:new).with(
          school: school,
          order_state: batch_job.order_state,
          std_device_cap: batch_job.allocation_delta,
        )

        expect(mock_service).to have_received(:disable_user_notifications!)
      end

      it 'does not update sent_notification flag' do
        expect {
          described_class.perform_now([batch_job], send_notifications: false)
        }.not_to change { batch_job.reload.sent_notification }.from(false)
      end
    end

    context 'when send_notification is true' do
      let!(:school) { create(:school) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order') }

      it 'sends notifications' do
        mock_service = instance_double(SchoolOrderStateAndCapUpdateService)
        allow(SchoolOrderStateAndCapUpdateService).to receive(:new).and_return(mock_service)
        allow(mock_service).to receive(:disable_user_notifications!)
        allow(mock_service).to receive(:call)

        described_class.perform_now([batch_job], send_notifications: true)

        expect(SchoolOrderStateAndCapUpdateService).to have_received(:new).with(
          school: school,
          order_state: batch_job.order_state,
          std_device_cap: batch_job.allocation_delta,
        )

        expect(mock_service).not_to have_received(:disable_user_notifications!)
      end

      it 'updates sent_notification flag' do
        expect {
          described_class.perform_now([batch_job])
        }.to change { batch_job.reload.sent_notification }.from(false).to(true)
      end
    end

    context 'school does not have an allocation' do
      let!(:school) { create(:school) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order') }

      it 'creates and sets the allocation' do
        described_class.perform_now([batch_job])

        expect(school.std_device_allocation.allocation).to be(3)
      end

      it 'creates and sets the cap' do
        described_class.perform_now([batch_job])

        expect(school.std_device_allocation.cap).to be(3)
      end
    end

    context 'for school that cannot order' do
      let!(:school) { create(:school, :with_std_device_allocation) }

      context 'updating to can_order' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order') }

        it 'updates the allocation' do
          expect {
            described_class.perform_now([batch_job])
          }.to change { school.std_device_allocation.reload.allocation }.by(3)
        end

        it 'updates the cap to match allocation' do
          described_class.perform_now([batch_job])

          expect(school.std_device_allocation.reload.cap).to eql(school.std_device_allocation.reload.allocation)
        end

        it 'marks job as processed' do
          described_class.perform_now([batch_job])

          expect(batch_job.reload).to be_processed
        end
      end

      context 'maintaining cannot_order' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'cannot_order') }

        it 'updates the allocation' do
          expect {
            described_class.perform_now([batch_job])
          }.to change { school.std_device_allocation.reload.allocation }.by(3)
        end

        it 'leaves the cap as is' do
          expect {
            described_class.perform_now([batch_job])
          }.not_to(change { school.std_device_allocation.reload.cap })
        end

        it 'marks job as processed' do
          described_class.perform_now([batch_job])

          expect(batch_job.reload).to be_processed
        end
      end

      context 'reducing allocation' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'cannot_order') }

        it 'does not reduce allocation' do
          expect { described_class.perform_now([batch_job]) }.not_to(change { school.std_device_allocation.reload.allocation })
        end
      end

      context 'maintain part of allocation if already ordered' do
        let!(:school) { create(:school, :with_std_device_allocation_partially_ordered) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-100', order_state: 'cannot_order') }

        it 'reduces allocation to match ordered' do
          described_class.perform_now([batch_job])
          expect(school.std_device_allocation.reload.allocation).to eq(school.std_device_allocation.devices_ordered)
        end
      end

      context 'maintain allocation if already ordered' do
        let!(:school) { create(:school, :with_std_device_allocation_fully_ordered) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'cannot_order') }

        it 'does not update the allocation' do
          expect {
            described_class.perform_now([batch_job])
          }.not_to change(school.std_device_allocation.reload, :allocation)
        end
      end
    end

    context 'for school that can order' do
      let(:school) { create(:school, :with_std_device_allocation, :in_lockdown) }

      context 'maintaining can_order' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order') }

        it 'updates the allocation' do
          expect {
            described_class.perform_now([batch_job])
          }.to change { school.std_device_allocation.reload.allocation }.by(3)
        end

        it 'updates the cap to match allocation' do
          described_class.perform_now([batch_job])

          expect(school.std_device_allocation.reload.cap).to eql(school.std_device_allocation.reload.allocation)
        end

        it 'marks job as processed' do
          described_class.perform_now([batch_job])

          expect(batch_job.reload).to be_processed
        end
      end

      context 'updating to cannot_order' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'cannot_order') }

        it 'updates the allocation' do
          expect {
            described_class.perform_now([batch_job])
          }.to change { school.std_device_allocation.reload.allocation }.by(3)
        end

        it 'changes the cap to equal raw_devices_ordered when raw_devices_ordered is zero' do
          described_class.perform_now([batch_job])

          expect(school.std_device_allocation.reload.cap).to be(school.std_device_allocation.reload.raw_devices_ordered)
        end

        context 'when partially_ordered' do
          let!(:school) { create(:school, :with_std_device_allocation_partially_ordered) }

          it 'changes the cap to equal raw_devices_ordered' do
            described_class.perform_now([batch_job])

            expect(school.std_device_allocation.reload.cap).to be(school.std_device_allocation.reload.raw_devices_ordered)
          end
        end

        context 'when fully_ordered' do
          let!(:school) { create(:school, :with_std_device_allocation_fully_ordered) }

          it 'changes the cap to equal raw_devices_ordered' do
            described_class.perform_now([batch_job])

            expect(school.std_device_allocation.reload.cap).to be(school.std_device_allocation.reload.raw_devices_ordered)
          end
        end

        context 'when school partially_ordered with a zero delta' do
          let!(:school) { create(:school, :with_std_device_allocation_partially_ordered) }
          let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '0', order_state: 'cannot_order') }

          it 'does not change the allocation' do
            expect { described_class.perform_now([batch_job]) }.not_to(change { school.std_device_allocation.reload.allocation })
          end

          it 'changes the cap to equal raw_devices_ordered' do
            described_class.perform_now([batch_job])

            expect(school.std_device_allocation.reload.cap).to be(school.std_device_allocation.reload.raw_devices_ordered)
          end
        end

        it 'marks job as processed' do
          described_class.perform_now([batch_job])

          expect(batch_job.reload).to be_processed
        end
      end

      context 'reducing allocation' do
        let!(:school) { create(:school, :with_std_device_allocation_partially_ordered) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'cannot_order') }

        it 'reduces allocation' do
          expect {
            described_class.perform_now([batch_job])
          }.to change { school.std_device_allocation.reload.allocation }.by(-1)
        end
      end

      context 'maintain part of allocation if already ordered' do
        let!(:school) { create(:school, :with_std_device_allocation_partially_ordered) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-100', order_state: 'cannot_order') }

        it 'reduces allocation to match ordered' do
          described_class.perform_now([batch_job])
          expect(school.std_device_allocation.reload.allocation).to eq(school.std_device_allocation.devices_ordered)
        end
      end

      context 'maintain allocation if already ordered' do
        let!(:school) { create(:school, :with_std_device_allocation_fully_ordered) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'cannot_order') }

        it 'does not update the allocation' do
          expect {
            described_class.perform_now([batch_job])
          }.not_to change(school.std_device_allocation.reload, :allocation)
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
      let(:school1_allocation) { school1.std_device_allocation.reload.allocation }
      let(:school1_devices_available_to_order) { school1.std_device_allocation.reload.devices_available_to_order }

      let(:school2) { rb.schools.last }
      let(:school2_allocation) { school2.std_device_allocation.reload.allocation }
      let(:school2_devices_available_to_order) { school2.std_device_allocation.reload.devices_available_to_order }

      before do
        create_list(:school, 2,
                    :centrally_managed,
                    responsible_body: rb)

        create(:school_device_allocation, :with_std_allocation, :partially_ordered, school: school1)
        create(:school_device_allocation, :with_std_allocation, :partially_ordered, school: school2)

        rb.add_school_to_virtual_cap_pools!(school1)
        rb.add_school_to_virtual_cap_pools!(school2)

        batch_job
      end

      it 'updates the allocation' do
        expect {
          described_class.perform_now([batch_job])
        }.to change { school1.std_device_allocation.reload.raw_allocation }.by(3)
      end

      context 'increasing the allocation for multiple schools in the same pool' do
        let(:batch_allocation_job1) do
          create(:allocation_batch_job, urn: school1.urn, allocation_delta: '100', order_state: 'can_order')
        end
        let(:batch_allocation_job2) do
          create(:allocation_batch_job, urn: school2.urn, allocation_delta: '100', order_state: 'can_order')
        end

        it 'increases the allocation of the pool' do
          expect {
            described_class.perform_now([batch_allocation_job1, batch_allocation_job2])
          }.to change { school1.std_device_allocation.reload.allocation }.by(200)
        end
      end

      it 'updates the cap to match allocation when order_status is can_order' do
        described_class.perform_now([batch_job])

        sum = school1.std_device_allocation.reload.raw_cap + school2.std_device_allocation.reload.raw_cap
        expect(school1.std_device_allocation.cap).to eql(sum)
        expect(school2.std_device_allocation.cap).to eql(sum)

        expect(school1.std_device_allocation.raw_cap).to eql(school1.std_device_allocation.raw_allocation)
      end

      context 'updating to cannot_order' do
        let(:batch_allocation_job1) do
          create(:allocation_batch_job, urn: school1.urn, allocation_delta: '100', order_state: 'cannot_order')
        end
        let(:batch_allocation_job2) do
          create(:allocation_batch_job, urn: school2.urn, allocation_delta: '100', order_state: 'cannot_order')
        end

        it 'updates the raw_cap to match raw_devices_ordered' do
          described_class.perform_now([batch_allocation_job1, batch_allocation_job2])

          expect(school1.std_device_allocation.raw_cap).to eql(school1.std_device_allocation.raw_devices_ordered)
          expect(school2.std_device_allocation.raw_cap).to eql(school2.std_device_allocation.raw_devices_ordered)
        end
      end

      context 'updating to cannot_order with a zero delta' do
        let(:batch_allocation_job1) do
          create(:allocation_batch_job, urn: school1.urn, allocation_delta: '0', order_state: 'cannot_order')
        end
        let(:batch_allocation_job2) do
          create(:allocation_batch_job, urn: school2.urn, allocation_delta: '0', order_state: 'cannot_order')
        end

        it 'does not change the allocation' do
          expect { described_class.perform_now([batch_allocation_job1]) }.not_to(change { school1.std_device_allocation.reload.allocation })
          expect { described_class.perform_now([batch_allocation_job2]) }.not_to(change { school2.std_device_allocation.reload.allocation })
        end

        it 'does not change the raw_allocation' do
          expect { described_class.perform_now([batch_allocation_job1]) }.not_to(change { school1.std_device_allocation.reload.raw_allocation })
          expect { described_class.perform_now([batch_allocation_job2]) }.not_to(change { school2.std_device_allocation.reload.raw_allocation })
        end

        it 'updates the raw_cap to match raw_devices_ordered' do
          described_class.perform_now([batch_allocation_job1, batch_allocation_job2])

          expect(school1.std_device_allocation.raw_cap).to eql(school1.std_device_allocation.raw_devices_ordered)
          expect(school2.std_device_allocation.raw_cap).to eql(school2.std_device_allocation.raw_devices_ordered)
        end

        it 'returns false for devices_available_to_order?' do
          described_class.perform_now([batch_allocation_job1, batch_allocation_job2])

          expect(school1.std_device_allocation.reload.devices_available_to_order?).to be(false)
          expect(school2.std_device_allocation.reload.devices_available_to_order?).to be(false)
        end
      end

      context 'reducing allocation' do
        let(:batch_deallocation_job) { create(:allocation_batch_job, urn: school1.urn, allocation_delta: '-1', order_state: 'can_order') }

        it 'reduces allocation' do
          expect {
            described_class.perform_now([batch_deallocation_job])
          }.to change { school1.std_device_allocation.reload.raw_allocation }.by(-1)
        end
      end

      context 'reduce and maintain part of allocation if already ordered' do
        let!(:devices_available_to_deallocate) { [school1_devices_available_to_order, 198].min }
        let(:batch_deallocation_job1) do
          create(:allocation_batch_job, urn: school1.urn, allocation_delta: '-99', order_state: 'can_order')
        end
        let(:batch_deallocation_job2) do
          create(:allocation_batch_job, urn: school2.urn, allocation_delta: '-99', order_state: 'can_order')
        end

        it 'reduces allocation to match ordered' do
          expect {
            described_class.perform_now([batch_deallocation_job1, batch_deallocation_job2])
          }.to change { school1.std_device_allocation.reload.allocation }.by(-devices_available_to_deallocate)
        end
      end

      context 'reduce and maintain all of allocation if already fully ordered' do
        let!(:school) { create(:school, :with_std_device_allocation_fully_ordered) }
        let(:batch_deallocation_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'can_order') }

        it 'does not update the allocation' do
          expect {
            described_class.perform_now([batch_deallocation_job])
          }.not_to change(school.std_device_allocation.reload, :allocation)
        end
      end
    end
  end
end
