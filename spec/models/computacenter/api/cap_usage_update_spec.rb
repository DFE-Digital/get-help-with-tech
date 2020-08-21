require 'rails_helper'

RSpec.describe Computacenter::API::CapUsageUpdate do
  let(:args) do
    {
      'capType' => 'DfE_RemainThresholdQty|Std_Device',
      'shipTo' => '123456',
      'capAmount' => 100,
      'usedCap' => 20,
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
    let!(:school) { create(:school, computacenter_reference: '123456') }
    let!(:allocation) { create(:school_device_allocation, school: school, device_type: 'std_device') }

    it 'updates the correct allocation with the given usedCap' do
      expect { cap_usage_update.apply! }.to change { allocation.reload.devices_ordered }.from(0).to(20)
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

    context 'when no errors are raised' do
      it 'sets the status to "succeeded"' do
        cap_usage_update.apply!
        expect(cap_usage_update.status).to eq('succeeded')
      end
    end
  end
end
