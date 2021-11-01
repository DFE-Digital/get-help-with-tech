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
        mock_service = instance_double(UpdateSchoolDevicesService)
        allow(UpdateSchoolDevicesService).to receive(:new).and_return(mock_service)
        allow(mock_service).to receive(:call)

        described_class.perform_now(batch_job)

        expect(UpdateSchoolDevicesService).to have_received(:new).with(
          school: school,
          order_state: batch_job.order_state,
          laptop_allocation: batch_job.allocation_delta,
          laptop_cap: batch_job.allocation_delta,
          notify_computacenter: true,
          notify_school: false,
          recalculate_vcaps: true,
        )
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
        mock_service = instance_double(UpdateSchoolDevicesService)
        allow(UpdateSchoolDevicesService).to receive(:new).and_return(mock_service)
        allow(mock_service).to receive(:call)

        described_class.perform_now(batch_job)

        expect(UpdateSchoolDevicesService).to have_received(:new).with(
          school: school,
          order_state: batch_job.order_state,
          laptop_allocation: batch_job.allocation_delta,
          laptop_cap: batch_job.allocation_delta,
          notify_computacenter: true,
          notify_school: true,
          recalculate_vcaps: true,
        )
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

        expect(school.reload.raw_allocation(:laptop)).to be(3)
      end

      it 'creates and sets the cap' do
        described_class.perform_now(batch_job)

        expect(school.reload.cap(:laptop)).to be(3)
      end
    end

    context 'for school that cannot order' do
      let!(:school) { create(:school, laptops: [1, 0, 0]) }

      context 'updating to can_order' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order') }

        it 'updates the allocation' do
          expect {
            described_class.perform_now(batch_job)
          }.to change { school.reload.allocation(:laptop) }.by(3)
        end

        it 'updates the cap to match allocation' do
          described_class.perform_now(batch_job)

          expect(school.reload.cap(:laptop)).to eql(school.reload.allocation(:laptop))
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
          }.to change { school.reload.allocation(:laptop) }.by(3)
        end

        it 'leaves the cap as is' do
          expect {
            described_class.perform_now(batch_job)
          }.not_to(change { school.reload.cap(:laptop) })
        end

        it 'marks job as processed' do
          described_class.perform_now(batch_job)

          expect(batch_job.reload).to be_processed
        end
      end

      context 'reducing allocation' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'cannot_order') }

        it 'does not reduce allocation' do
          expect { described_class.perform_now(batch_job) }.not_to(change { school.reload.allocation(:laptop) })
        end
      end

      context 'maintain part of allocation if already ordered' do
        let!(:school) { create(:school, laptops: [2, 2, 1]) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-100', order_state: 'cannot_order') }

        it 'reduces allocation to match ordered' do
          described_class.perform_now(batch_job)
          expect(school.reload.allocation(:laptop)).to eq(school.devices_ordered(:laptop))
        end
      end

      context 'maintain allocation if already ordered' do
        let!(:school) { create(:school, laptops: [1, 1, 1]) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'cannot_order') }

        it 'does not update the allocation' do
          expect { described_class.perform_now(batch_job) }
            .not_to(change { school.reload.allocation(:laptop) })
        end
      end
    end

    context 'for school that can order' do
      let(:school) { create(:school, :in_lockdown, laptops: [1, 0, 0]) }

      context 'maintaining can_order' do
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '3', order_state: 'can_order') }

        it 'updates the allocation' do
          expect {
            described_class.perform_now(batch_job)
          }.to change { school.reload.allocation(:laptop) }.by(3)
        end

        it 'updates the cap to match allocation' do
          described_class.perform_now(batch_job)

          expect(school.reload.cap(:laptop)).to eql(school.reload.allocation(:laptop))
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
          }.to change { school.reload.allocation(:laptop) }.by(3)
        end

        it 'changes the cap to equal raw_devices_ordered when raw_devices_ordered is zero' do
          described_class.perform_now(batch_job)

          expect(school.reload.cap(:laptop)).to be(school.reload.raw_devices_ordered(:laptop))
        end

        context 'when partially_ordered' do
          let!(:school) { create(:school, laptops: [2, 2, 1]) }

          it 'changes the cap to equal raw_devices_ordered' do
            described_class.perform_now(batch_job)

            expect(school.reload.cap(:laptop)).to be(school.reload.raw_devices_ordered(:laptop))
          end
        end

        context 'when fully_ordered' do
          let!(:school) { create(:school, laptops: [1, 1, 1]) }

          it 'changes the cap to equal raw_devices_ordered' do
            described_class.perform_now(batch_job)

            expect(school.reload.cap(:laptop)).to be(school.reload.raw_devices_ordered(:laptop))
          end
        end

        context 'when school partially_ordered with a zero delta' do
          let!(:school) { create(:school, laptops: [2, 2, 1]) }
          let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '0', order_state: 'cannot_order') }

          it 'does not change the allocation' do
            expect { described_class.perform_now(batch_job) }.not_to(change { school.reload.allocation(:laptop) })
          end

          it 'changes the cap to equal raw_devices_ordered' do
            described_class.perform_now(batch_job)

            expect(school.reload.cap(:laptop)).to be(school.reload.raw_devices_ordered(:laptop))
          end
        end

        it 'marks job as processed' do
          described_class.perform_now(batch_job)

          expect(batch_job.reload).to be_processed
        end
      end

      context 'reducing allocation' do
        let!(:school) { create(:school, laptops: [2, 2, 1]) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'cannot_order') }

        it 'reduces allocation' do
          expect {
            described_class.perform_now(batch_job)
          }.to change { school.reload.allocation(:laptop) }.by(-1)
        end
      end

      context 'maintain part of allocation if already ordered' do
        let!(:school) { create(:school, laptops: [2, 2, 1]) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-100', order_state: 'cannot_order') }

        it 'reduces allocation to match ordered' do
          described_class.perform_now(batch_job)
          expect(school.reload.allocation(:laptop)).to eq(school.devices_ordered(:laptop))
        end
      end

      context 'maintain allocation if already ordered' do
        let!(:school) { create(:school, laptops: [1, 1, 1]) }
        let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'cannot_order') }

        it 'does not update the allocation' do
          expect { described_class.perform_now(batch_job) }.not_to(change { school.reload.allocation(:laptop) })
        end
      end
    end

    context 'when school is part of virtual cap pool' do
      let(:batch_job) { create(:allocation_batch_job, urn: school1.urn, allocation_delta: '3', order_state: 'can_order') }

      let(:rb) { create(:trust, :manages_centrally, :vcap_feature_flag) }

      let(:school1) { rb.schools.first }
      let(:school1_allocation) { school1.reload.allocation(:laptop) }
      let(:school1_devices_available_to_order) { school1.reload.devices_available_to_order(:laptop) }

      let(:school2) { rb.schools.last }
      let(:school2_allocation) { school2.reload.allocation(:laptop) }
      let(:school2_devices_available_to_order) { school2.reload.devices_available_to_order(:laptop) }

      before do
        create_list(:school, 2, :centrally_managed, responsible_body: rb, laptops: [2, 2, 1])
        rb.calculate_vcaps!
        batch_job
      end

      it 'updates the allocation' do
        expect {
          described_class.perform_now(batch_job)
        }.to change { school1.reload.raw_allocation(:laptop) }.by(3)
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
            described_class.perform_now(batch_allocation_job1)
            described_class.perform_now(batch_allocation_job2)
          }.to change { school1.reload.allocation(:laptop) }.by(200)
        end
      end

      it 'updates the cap to match allocation when order_status is can_order' do
        described_class.perform_now(batch_job)

        sum = school1.reload.raw_cap(:laptop) + school2.reload.raw_cap(:laptop)
        expect(school1.cap(:laptop)).to eql(sum)
        expect(school2.cap(:laptop)).to eql(sum)

        expect(school1.raw_cap(:laptop)).to eql(school1.raw_allocation(:laptop))
      end

      context 'updating to cannot_order' do
        let(:batch_allocation_job1) do
          create(:allocation_batch_job, urn: school1.urn, allocation_delta: '100', order_state: 'cannot_order')
        end
        let(:batch_allocation_job2) do
          create(:allocation_batch_job, urn: school2.urn, allocation_delta: '100', order_state: 'cannot_order')
        end

        it 'updates the raw_cap to match raw_devices_ordered' do
          described_class.perform_now(batch_allocation_job1)
          described_class.perform_now(batch_allocation_job2)

          expect(school1.reload.raw_cap(:laptop)).to eql(school1.reload.raw_devices_ordered(:laptop))
          expect(school2.reload.raw_cap(:laptop)).to eql(school2.reload.raw_devices_ordered(:laptop))
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
          expect { described_class.perform_now(batch_allocation_job1) }.not_to(change { school1.reload.allocation(:laptop) })
          expect { described_class.perform_now(batch_allocation_job2) }.not_to(change { school2.reload.allocation(:laptop) })
        end

        it 'does not change the raw_allocation' do
          expect { described_class.perform_now(batch_allocation_job1) }.not_to(change { school1.reload.raw_allocation(:laptop) })
          expect { described_class.perform_now(batch_allocation_job2) }.not_to(change { school2.reload.raw_allocation(:laptop) })
        end

        it 'updates the raw_cap to match raw_devices_ordered' do
          described_class.perform_now(batch_allocation_job1)
          described_class.perform_now(batch_allocation_job2)

          expect(school1.reload.raw_cap(:laptop)).to eql(school1.reload.raw_devices_ordered(:laptop))
          expect(school2.reload.raw_cap(:laptop)).to eql(school2.reload.raw_devices_ordered(:laptop))
        end

        it 'returns false for devices_available_to_order?' do
          described_class.perform_now(batch_allocation_job1)
          described_class.perform_now(batch_allocation_job2)

          expect(school1.reload.devices_available_to_order?(:laptop)).to be(false)
          expect(school2.reload.devices_available_to_order?(:laptop)).to be(false)
        end
      end

      context 'reducing allocation' do
        let(:batch_deallocation_job) { create(:allocation_batch_job, urn: school1.urn, allocation_delta: '-1', order_state: 'can_order') }

        it 'reduces allocation' do
          expect {
            described_class.perform_now(batch_deallocation_job)
          }.to change { school1.reload.raw_allocation(:laptop) }.by(-1)
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
            described_class.perform_now(batch_deallocation_job1)
            described_class.perform_now(batch_deallocation_job2)
          }.to change { school1.reload.allocation(:laptop) }.by(-devices_available_to_deallocate)
        end
      end

      context 'reduce and maintain all of allocation if already fully ordered' do
        let!(:school) { create(:school, laptops: [1, 1, 1]) }
        let(:batch_deallocation_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'can_order') }

        it 'does not update the allocation' do
          expect { described_class.perform_now(batch_deallocation_job) }
            .not_to(change { school.reload.allocation(:laptop) })
        end
      end
    end
  end
end
