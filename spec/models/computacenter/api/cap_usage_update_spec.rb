require 'rails_helper'

RSpec.describe Computacenter::API::CapUsageUpdate do
  let(:args) do
    {
      'capType' => 'DfE_RemainThresholdQty|Std_Device',
      'shipTo' => '123456',
      'capAmount' => 100,
      'usedCap' => 100,
    }
  end

  subject(:cap_usage_update) { described_class.new(args) }

  describe '#initialize' do
    context 'given a hash with string keys' do
      it 'sets cap_type to the given capType' do
        expect(cap_usage_update.cap_type).to eq(args['capType'])
      end

      it 'sets ship_to to the given shipTo' do
        expect(cap_usage_update.ship_to).to eq(args['shipTo'])
      end

      it 'sets cap_amount to the given capAmount' do
        expect(cap_usage_update.cap_amount).to eq(args['capAmount'])
      end

      it 'sets cap_used to the given usedCap' do
        expect(cap_usage_update.cap_used).to eq(args['usedCap'])
      end
    end
  end

  describe '#apply!' do
    let(:preorder) { create(:preorder_information, :rb_will_order, :does_not_need_chromebooks, status: 'ready') }
    let!(:school) { create(:school, :in_lockdown, preorder_information: preorder, computacenter_reference: '123456') }
    let!(:allocation) { create(:school_device_allocation, school: school, device_type: 'std_device', cap: 100, allocation: 100, devices_ordered: 10) }

    it 'updates the correct allocation with the given usedCap' do
      expect { cap_usage_update.apply! }.to change { allocation.reload.devices_ordered }.from(10).to(100)
    end

    it 'refresh preorder status' do
      expect {
        cap_usage_update.apply!
      }.to change { school.reload.device_ordering_status }.from('ready').to('ordered')
    end

    it 'logs to devices_ordered_updates' do
      expect {
        cap_usage_update.apply!
      }.to change { Computacenter::DevicesOrderedUpdate.count }.by(1)

      log = Computacenter::DevicesOrderedUpdate.last

      expect(log.cap_type).to eql(args['capType'])
      expect(log.ship_to).to eql(args['shipTo'])
      expect(log.cap_amount).to eql(args['capAmount'])
      expect(log.cap_used).to eql(args['usedCap'])

      expect(log.school).to eql(school)
      expect(school.devices_ordered_updates).to include(log)
    end

    context 'if the given cap_amount does not match the stored allocation' do
      let(:mock_mismatch) { instance_double(Computacenter::API::CapUsageUpdate::CapMismatch) }

      before do
        cap_usage_update.cap_amount += 1
        allow(Computacenter::API::CapUsageUpdate::CapMismatch).to receive(:new).with(school, allocation).and_return(mock_mismatch)
        allow(mock_mismatch).to receive(:warn)
      end

      it 'logs a cap mismatch' do
        cap_usage_update.apply!
        expect(mock_mismatch).to have_received(:warn).with(101)
      end
    end

    context 'if the devices_ordered update triggers a cap update' do
      let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }
      let!(:school) { create(:school, :in_lockdown, :manages_orders, computacenter_reference: '123456', responsible_body: responsible_body) }

      let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest) }
      let(:exception) { Computacenter::OutgoingAPI::Error.new(cap_update_request: OpenStruct.new(body: 'body')) }

      before do
        stub_computacenter_outgoing_api_calls
        school.reload.std_device_allocation.update!(allocation: 103)
        WebMock.allow_net_connect!
        school.orders_managed_centrally!
        school.can_order!
        allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
        allow(mock_request).to receive(:post!).and_raise(exception)
      end

      it 'will not fail if the cap update were to fail' do
        expect { cap_usage_update.apply! }.not_to raise_error
        expect(cap_usage_update.status).to eq('succeeded')
      end
    end

    context 'when no errors are raised' do
      it 'sets the status to "succeeded"' do
        cap_usage_update.apply!
        expect(cap_usage_update.status).to eq('succeeded')
      end
    end

    context 'if the devices_ordered decreases' do
      let!(:user) { create(:user, :with_a_confirmed_techsource_account, orders_devices: true, responsible_body: school.responsible_body) }

      let(:args) do
        {
          'capType' => 'DfE_RemainThresholdQty|Std_Device',
          'shipTo' => '123456',
          'capAmount' => 100,
          'usedCap' => 1,
        }
      end

      it 'sends a notification to order if they can order' do
        expect {
          cap_usage_update.apply!
        }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order', 'deliver_now', params: { user: user, school: school }, args: [])
      end
    end

    context 'if the devices_ordered increases' do
      let!(:user) { create(:user, :with_a_confirmed_techsource_account, orders_devices: true, responsible_body: school.responsible_body) }

      let(:args) do
        {
          'capType' => 'DfE_RemainThresholdQty|Std_Device',
          'shipTo' => '123456',
          'capAmount' => 100,
          'usedCap' => 99,
        }
      end

      it 'does not send notification to order' do
        expect {
          cap_usage_update.apply!
        }.not_to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order', 'deliver_now', params: { user: user, school: school }, args: [])
      end
    end
  end
end
