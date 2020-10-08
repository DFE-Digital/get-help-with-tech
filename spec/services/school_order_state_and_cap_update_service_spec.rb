require 'rails_helper'

RSpec.describe SchoolOrderStateAndCapUpdateService do
  let(:school) { create(:school, order_state: 'cannot_order') }
  let(:new_order_state) { 'can_order' }
  let(:new_cap) { 2 }
  let(:allocation) { school.std_device_allocation }
  let(:device_type) { nil }

  subject(:service) { described_class.new(school: school, device_type: device_type) }

  describe '#update!' do
    let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest, timestamp: Time.zone.now, payload_id: '123456789') }

    before do
      allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
      allow(mock_request).to receive(:post!)
    end

    it 'updates the school with the given order_state' do
      expect { service.update!(cap: new_cap, order_state: new_order_state) }.to change(school, :order_state).from('cannot_order').to('can_order')
    end

    context 'when a std SchoolDeviceAllocation does not exist' do
      before do
        SchoolDeviceAllocation.delete_all
      end

      context 'when no device_type was given' do
        it 'creates a new std_device allocation record' do
          expect { service.update!(cap: new_cap, order_state: new_order_state) }.to change(school.device_allocations.by_device_type('std_device'), :count).by(1)
        end
      end

      context 'when a device_type was given' do
        let(:device_type) { 'coms_device' }

        it 'creates a new allocation record with the given device_type' do
          expect { service.update!(cap: new_cap, order_state: new_order_state) }.to change(school.device_allocations.by_device_type('coms_device'), :count).by(1)
        end

        context 'when the endpoint setting is present' do
          before do
            Settings.computacenter.outgoing_api.endpoint = 'HERE'
          end

          it 'sends an email to computacenter' do
            expect { service.update!(cap: new_cap, order_state: new_order_state) }.to have_enqueued_mail(ComputacenterMailer, :notify_of_comms_cap_change).once
          end
        end
      end
    end

    context 'when a SchoolDeviceAllocation of the right type exists' do
      let!(:allocation) { create(:school_device_allocation, :with_std_allocation, allocation: 7, school: school) }

      it 'does not create a new allocation record' do
        expect { service.update!(cap: new_cap, order_state: new_order_state) }.not_to change(SchoolDeviceAllocation, :count)
      end

      context 'changing order_state to can_order' do
        let(:new_order_state) { 'can_order' }

        it 'sets the new cap to match the full allocation, regardless of what was given' do
          service.update!(cap: 2, order_state: new_order_state)
          expect(allocation.reload.cap).to eq(7)
        end
      end
    end

    context 'changing order_state to can_order_for_specific_circumstances' do
      let!(:allocation) { create(:school_device_allocation, :with_std_allocation, allocation: 7, school: school) }
      let(:new_order_state) { 'can_order_for_specific_circumstances' }

      it 'sets the new cap to be the given cap' do
        service.update!(cap: 3, order_state: new_order_state)
        expect(allocation.reload.cap).to eq(3)
      end
    end

    context 'changing order_state to cannot_order' do
      let(:new_order_state) { 'cannot_order' }

      context 'with an existing allocation' do
        before do
          create(:school_device_allocation, :with_std_allocation,
                 school: school,
                 allocation: 7,
                 cap: 3,
                 devices_ordered: 1)
        end

        it 'sets the new cap to equal the devices_ordered, regardless of what was given' do
          service.update!(cap: 5, order_state: new_order_state)
          expect(allocation.cap).to eq(1)
        end
      end

      context 'with no existing allocation' do
        it 'sets the new cap to 0, regardless of what was given' do
          service.update!(cap: 5, order_state: new_order_state)
          expect(allocation.cap).to eq(0)
        end
      end
    end

    context 'when the endpoint setting is present' do
      before do
        Settings.computacenter.outgoing_api.endpoint = 'HERE'
      end

      it 'notifies the computacenter API' do
        service.update!(cap: 2, order_state: new_order_state)
        expect(mock_request).to have_received(:post!)
      end

      it 'records timestamp and payload_id on the allocation' do
        service.update!(cap: 2, order_state: new_order_state)
        allocation.reload
        expect(allocation.cap_update_request_timestamp).not_to be_nil
        expect(allocation.cap_update_request_payload_id).not_to be_nil
      end

      it 'sends an email to computacenter' do
        expect { service.update!(cap: new_cap, order_state: new_order_state) }.to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change).once
      end
    end

    context 'when the endpoint setting is not present' do
      before do
        Settings.computacenter.outgoing_api.endpoint = ''
      end

      it 'does not notify the computacenter API' do
        service.update!(cap: 2, order_state: new_order_state)
        expect(mock_request).not_to have_received(:post!)
      end

      it 'does not record timestamp and payload_id on the allocation' do
        service.update!(cap: 2, order_state: new_order_state)
        allocation.reload
        expect(allocation.cap_update_request_timestamp).to be_nil
        expect(allocation.cap_update_request_payload_id).to be_nil
      end

      it 'does not send an email to computacenter' do
        expect { service.update!(cap: new_cap, order_state: new_order_state) }.not_to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
      end
    end
  end
end
