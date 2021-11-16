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

    context 'case 1' do
      let(:school) { create(:school, :in_lockdown, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([0, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 2' do
      let(:school) { create(:school, :in_lockdown, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([0, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 3' do
      let(:school) { create(:school, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([0, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 4' do
      let(:school) { create(:school, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([0, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 5' do
      let(:school) { create(:school, :in_lockdown, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([0, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 6' do
      let(:school) { create(:school, :in_lockdown, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([0, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 7' do
      let(:school) { create(:school, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([0, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 8' do
      let(:school) { create(:school, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([0, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 9' do
      let(:school) { create(:school, :in_lockdown, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([1, 1, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 10' do
      let(:school) { create(:school, :in_lockdown, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([1, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 11' do
      let(:school) { create(:school, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([1, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 12' do
      let(:school) { create(:school, laptops: [0, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([0, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([1, 1, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 13' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 14' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 15' do
      let(:school) { create(:school, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 16' do
      let(:school) { create(:school, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 17' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 18' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 19' do
      let(:school) { create(:school, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 20' do
      let(:school) { create(:school, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 21' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 1, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 22' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 23' do
      let(:school) { create(:school, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 24' do
      let(:school) { create(:school, laptops: [5, 0, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 1, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 25' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([3, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 26' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([3, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 27' do
      let(:school) { create(:school, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([3, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 28' do
      let(:school) { create(:school, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([3, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 29' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 1, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 30' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 31' do
      let(:school) { create(:school, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 32' do
      let(:school) { create(:school, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 1, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 33' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 34' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 35' do
      let(:school) { create(:school, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 36' do
      let(:school) { create(:school, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 37' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 3, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 38' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 39' do
      let(:school) { create(:school, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 0, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 40' do
      let(:school) { create(:school, laptops: [5, 2, 0]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 0, 0])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 3, 0])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 41' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 42' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 43' do
      let(:school) { create(:school, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 1, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 44' do
      let(:school) { create(:school, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 1, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 45' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 46' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 47' do
      let(:school) { create(:school, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 1, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 48' do
      let(:school) { create(:school, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 1, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([4, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 49' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 50' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 51' do
      let(:school) { create(:school, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 1, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 52' do
      let(:school) { create(:school, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 1, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 53' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 3, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 54' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 55' do
      let(:school) { create(:school, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 1, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 1, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 56' do
      let(:school) { create(:school, laptops: [5, 2, 1]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 1, 1])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 3, 1])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 57' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 58' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 59' do
      let(:school) { create(:school, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 60' do
      let(:school) { create(:school, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -3, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 61' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 62' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 63' do
      let(:school) { create(:school, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 64' do
      let(:school) { create(:school, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 65' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 66' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 67' do
      let(:school) { create(:school, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 68' do
      let(:school) { create(:school, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 69' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 3, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 70' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 71' do
      let(:school) { create(:school, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 2, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 72' do
      let(:school) { create(:school, laptops: [5, 2, 2]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 2, 2])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 3, 2])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 73' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 5, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 74' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 5, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 75' do
      let(:school) { create(:school, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 5, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 76' do
      let(:school) { create(:school, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 5, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 77' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 5, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 78' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 5, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 79' do
      let(:school) { create(:school, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 5, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 80' do
      let(:school) { create(:school, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 5, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 81' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 6, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 82' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 5, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 83' do
      let(:school) { create(:school, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 5, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 84' do
      let(:school) { create(:school, laptops: [5, 5, 5]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 5, 5])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 6, 5])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 85' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 86' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 87' do
      let(:school) { create(:school, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 88' do
      let(:school) { create(:school, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: -1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 89' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 90' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 91' do
      let(:school) { create(:school, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 92' do
      let(:school) { create(:school, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 0, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([5, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 93' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 94' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 95' do
      let(:school) { create(:school, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 96' do
      let(:school) { create(:school, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 1, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([6, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 97' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 3, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([8, 8, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 98' do
      let(:school) { create(:school, :in_lockdown, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 3, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([8, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 99' do
      let(:school) { create(:school, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 3, order_state: :cannot_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([8, 7, 7])
        expect(batch_job.reload).to be_processed
      end
    end

    context 'case 100' do
      let(:school) { create(:school, laptops: [5, 7, 7]) }
      let(:batch_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: 3, order_state: :can_order) }

      it 'updates laptop allocation numbers' do
        expect(school.laptops).to eq([5, 7, 7])
        described_class.perform_now(batch_job)
        school.reload
        expect(school.laptops).to eq([8, 8, 7])
        expect(batch_job.reload).to be_processed
      end
    end
  end

  context 'when school is part of virtual cap pool' do
    let(:batch_job) { create(:allocation_batch_job, urn: school1.urn, allocation_delta: '3', order_state: 'can_order') }

    let(:rb) { create(:trust, :manages_centrally, :vcap) }

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

      expect(school1.reload.cap(:laptop)).to eq(6)
      expect(school2.reload.cap(:laptop)).to eq(6)

      expect(school1.raw_cap(:laptop)).to eql(school1.raw_allocation(:laptop))
    end

    context 'updating to cannot_order' do
      let(:batch_allocation_job1) do
        create(:allocation_batch_job, urn: school1.urn, allocation_delta: '100', order_state: 'cannot_order')
      end
      let(:batch_allocation_job2) do
        create(:allocation_batch_job, urn: school2.urn, allocation_delta: '100', order_state: 'cannot_order')
      end

      it 'do not update caps' do
        described_class.perform_now(batch_allocation_job1)
        described_class.perform_now(batch_allocation_job2)

        expect(school1.reload.cap(:laptop)).to eq(2)
        expect(school2.reload.cap(:laptop)).to eq(2)
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

      it 'do not updates the cap' do
        described_class.perform_now(batch_allocation_job1)
        described_class.perform_now(batch_allocation_job2)

        expect(school1.reload.cap(:laptop)).to be(2)
        expect(school2.reload.cap(:laptop)).to be(2)
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
        }.to change { school1.reload.allocation(:laptop) }.by(-2)
      end
    end

    context 'reduce and maintain all of allocation if already fully ordered' do
      let!(:school) { create(:school, laptops: [1, 2, 2]) }
      let(:batch_deallocation_job) { create(:allocation_batch_job, urn: school.urn, allocation_delta: '-1', order_state: 'can_order') }

      it 'does not update the allocation' do
        expect { described_class.perform_now(batch_deallocation_job) }
          .not_to(change { school.reload.allocation(:laptop) })
      end
    end
  end
end
