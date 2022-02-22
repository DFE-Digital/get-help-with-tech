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
    let!(:cap_usage_update_payload) { Computacenter::API::CapUsageUpdatePayload.create!(payload_xml: '<xml></xml>') }

    let!(:school) do
      create(:school,
             :centrally_managed,
             :in_lockdown,
             :does_not_need_chromebooks,
             computacenter_reference: '123456',
             laptops: [100, 100, 10])
    end

    it 'updates the correct allocation with the given usedCap' do
      expect { cap_usage_update.apply! }.to change { school.reload.devices_ordered(:laptop) }.from(10).to(100)
    end

    it 'refresh preorder status' do
      expect {
        cap_usage_update.apply!
      }.to change { school.reload.preorder_status }.from('rb_can_order').to('ordered')
    end

    it 'logs to devices_ordered_updates' do
      expect {
        cap_usage_update.apply!(cap_usage_update_payload_id: cap_usage_update_payload.id)
      }.to change { Computacenter::DevicesOrderedUpdate.count }.by(1)

      log = Computacenter::DevicesOrderedUpdate.last

      expect(log.cap_type).to eql(args['capType'])
      expect(log.ship_to).to eql(args['shipTo'])
      expect(log.cap_amount).to eql(args['capAmount'])
      expect(log.cap_used).to eql(args['usedCap'])
      expect(log.cap_usage_update_payload_id).to eq(cap_usage_update_payload.id)

      expect(log.school).to eql(school)
      expect(school.devices_ordered_updates).to include(log)
    end

    context 'if the given cap_amount does not match the stored allocation' do
      let(:mock_mismatch) { instance_double(Computacenter::API::CapUsageUpdate::CapMismatch) }

      before do
        cap_usage_update.cap_amount += 1
        allow(Computacenter::API::CapUsageUpdate::CapMismatch)
          .to receive(:new).with(school, :laptop).and_return(mock_mismatch)
        allow(mock_mismatch).to receive(:warn)
      end

      it 'logs a cap mismatch' do
        cap_usage_update.apply!
        expect(mock_mismatch).to have_received(:warn).with(101)
      end
    end

    context 'if the devices_ordered update triggers a cap update' do
      let(:responsible_body) { create(:trust, :manages_centrally, :vcap) }
      let!(:school) { create(:school, :in_lockdown, :manages_orders, computacenter_reference: '123456', responsible_body:) }

      let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest) }
      let(:exception) { Computacenter::OutgoingAPI::Error.new(cap_update_request: OpenStruct.new(body: 'body')) }

      before do
        stub_computacenter_outgoing_api_calls
        UpdateSchoolDevicesService.new(school:, laptop_allocation: 103).call
        WebMock.allow_net_connect!
        SchoolSetWhoManagesOrdersService.new(school, :responsible_body).call
        UpdateSchoolDevicesService.new(school:, order_state: :can_order).call
        allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
        allow(mock_request).to receive(:post).and_raise(exception)
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
        }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order', 'deliver_now', params: { user:, school: }, args: [])
      end

      it 'sends no notifications when notify_decreases is false' do
        expect {
          cap_usage_update.apply!(notify_decreases: false)
        }.not_to have_enqueued_mail(ComputacenterMailer, :user_can_order)
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
        }.not_to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order).with(params: { user:, school: }, args: [])
      end
    end
  end

  context 'when the school successfully ordered over their allocation' do
    let(:school) { create(:school, laptops: [1, 1, 1]) }
    let(:computacenter_reference) { school.computacenter_reference }
    let(:allocation) { school.allocation(:laptop) }
    let(:cap) { school.cap(:laptop) }
    let(:devices_ordered) { cap + 1 }

    let(:args) do
      {
        'capType' => 'DfE_RemainThresholdQty|Std_Device',
        'shipTo' => computacenter_reference,
        'capAmount' => cap,
        'usedCap' => devices_ordered,
      }
    end

    let(:cap_usage_update) { Computacenter::API::CapUsageUpdate.new(args) }

    before { stub_computacenter_outgoing_api_calls }

    it 'updates the cap but not the allocation' do
      cap_usage_update.apply!
      expect(school.reload.cap(:laptop)).to eq(devices_ordered)
      expect(school.reload.allocation(:laptop)).to eq(allocation)
    end
  end
end
