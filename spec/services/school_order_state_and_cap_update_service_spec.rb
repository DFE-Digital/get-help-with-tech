require 'rails_helper'

RSpec.describe SchoolOrderStateAndCapUpdateService do
  let(:preorder) { create(:preorder_information, :does_not_need_chromebooks, who_will_order_devices: :responsible_body) }
  let(:school) { create(:school, order_state: 'cannot_order', preorder_information: preorder) }
  let(:new_order_state) { 'can_order' }
  let(:new_cap) { 2 }
  let(:allocation) { school.std_device_allocation }
  let(:router_allocation) { school.coms_device_allocation }
  let(:device_type) { 'std_device' }
  let(:response) { OpenStruct.new(body: '<xml>test-response</xml>') }

  subject(:service) do
    described_class.new(school: school, order_state: new_order_state, std_device_cap: new_cap)
  end

  describe '#update!' do
    let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest, timestamp: Time.zone.now, payload_id: '123456789', body: '<xml>test-request</xml>') }
    let(:notifications) { instance_double(SchoolCanOrderDevicesNotifications) }

    before do
      allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
      allow(mock_request).to receive(:post!).and_return(response)
      allow(SchoolCanOrderDevicesNotifications).to receive(:new).with(school: school).and_return(notifications)
      allow(notifications).to receive(:call)
    end

    it 'updates the school with the given order_state' do
      expect { service.update! }.to change(school, :order_state).from('cannot_order').to('can_order')
    end

    it 'triggers notifications that the school can order' do
      service.update!
      expect(notifications).to have_received(:call)
    end

    context 'when a std SchoolDeviceAllocation does not exist' do
      before do
        SchoolDeviceAllocation.destroy_all
      end

      context 'when no device_type was given' do
        it 'creates a new std_device allocation record' do
          expect { service.update! }.to change(school.device_allocations.by_device_type('std_device'), :count).by(1)
        end

        it 'stores the request and response against the allocation' do
          service.update!
          expect(allocation.cap_update_calls).to be_present
          expect(allocation.cap_update_calls.last.request_body).to include('test-request')
          expect(allocation.cap_update_calls.last.response_body).to include('test-response')
        end
      end

      context 'when a device_type was given' do
        subject(:service) do
          described_class.new(school: school, order_state: new_order_state, coms_device_cap: new_cap)
        end

        it 'creates a new allocation record with the given device_type' do
          expect { service.update! }.to change(school.device_allocations.by_device_type('coms_device'), :count).by(1)
        end

        context 'when the endpoint setting is present' do
          it 'sends an email to computacenter' do
            expect(Settings.computacenter.outgoing_api.endpoint).to be_present

            expect { service.update! }.to have_enqueued_mail(ComputacenterMailer, :notify_of_comms_cap_change).once
          end
        end
      end
    end

    context 'when a SchoolDeviceAllocation of the right type exists' do
      let!(:allocation) { create(:school_device_allocation, :with_std_allocation, allocation: 7, school: school) }
      let!(:router_allocation) { create(:school_device_allocation, :with_coms_allocation, allocation: 5, school: school) }

      it 'does not create a new allocation record' do
        expect { service.update! }.not_to change(SchoolDeviceAllocation, :count)
      end

      context 'changing order_state to can_order' do
        it 'sets the new cap to match the full allocation, regardless of what was given' do
          service.update!
          expect(allocation.reload.cap).to eq(7)
          expect(router_allocation.reload.cap).to eq(5)
        end
      end
    end

    context 'when a school is centrally managed and the school is not in the virtual cap pool' do
      before do
        school.preorder_information.responsible_body_will_order_devices!
      end

      it 'adds the school to the virtual cap pool of the responsible body' do
        service.update!
        expect(school.responsible_body.std_device_pool.schools).to include(school)
      end
    end

    context 'changing order_state to can_order_for_specific_circumstances' do
      let!(:allocation) { create(:school_device_allocation, :with_std_allocation, allocation: 7, school: school) }
      let!(:router_allocation) { create(:school_device_allocation, :with_coms_allocation, allocation: 5, school: school) }

      subject(:service) do
        described_class.new(school: school, order_state: 'can_order_for_specific_circumstances', std_device_cap: 3, coms_device_cap: 2)
      end

      it 'sets the new cap to be the given cap' do
        service.update!
        expect(allocation.reload.cap).to eq(3)
        expect(router_allocation.reload.cap).to eq(2)
      end
    end

    context 'changing order_state to cannot_order' do
      let(:new_order_state) { 'cannot_order' }

      context 'with an existing allocation' do
        let(:new_cap) { 5 }

        before do
          create(:school_device_allocation, :with_std_allocation,
                 school: school,
                 allocation: 7,
                 cap: 3,
                 devices_ordered: 1)
        end

        it 'sets the new cap to equal the devices_ordered, regardless of what was given' do
          service.update!
          expect(allocation.cap).to eq(1)
        end

        it 'refreshes the status of the preorder' do
          expect {
            service.update!
          }.to change(preorder, :status)
        end
      end

      context 'with no existing allocation' do
        let(:new_cap) { 5 }

        it 'sets the new cap to 0, regardless of what was given' do
          service.update!
          expect(allocation.cap).to eq(0)
        end
      end
    end

    context 'when the endpoint setting is present' do
      before do
        raise 'Outgoing CC API endpoint not set' if Settings.computacenter.outgoing_api.endpoint.blank?
      end

      it 'notifies the computacenter API' do
        service.update!
        expect(mock_request).to have_received(:post!).twice
      end

      it 'records timestamp and payload_id on the allocation' do
        service.update!
        allocation.reload
        expect(allocation.cap_update_request_timestamp).not_to be_nil
        expect(allocation.cap_update_request_payload_id).not_to be_nil
      end

      it 'sends an email to computacenter' do
        expect { service.update! }.to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change).once
      end
    end

    context 'when the endpoint setting is not present' do
      before do
        allow(Settings.computacenter.outgoing_api).to receive(:endpoint).and_return(nil)
      end

      it 'does not notify the computacenter API' do
        service.update!
        expect(mock_request).not_to have_received(:post!)
      end

      it 'does not record timestamp and payload_id on the allocation' do
        service.update!
        allocation.reload
        expect(allocation.cap_update_request_timestamp).to be_nil
        expect(allocation.cap_update_request_payload_id).to be_nil
      end

      it 'does not send an email to computacenter' do
        expect { service.update! }.not_to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
      end
    end
  end
end
