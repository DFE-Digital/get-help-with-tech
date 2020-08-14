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
  let(:update) { described_class.new(args) }

  describe '#initialize' do
    context 'given a hash with string keys' do
      it 'sets cap_type to the given capType' do
        expect(update.cap_type).to eq(args['capType'])
      end

      it 'sets ship_to to the given shipTo' do
        expect(update.ship_to).to eq(args['shipTo'])
      end

      it 'sets cap_amount to the given capAmount' do
        expect(update.cap_amount).to eq(args['capAmount'])
      end

      it 'sets cap_used to the given usedCap' do
        expect(update.cap_used).to eq(args['usedCap'])
      end
    end
  end

  describe '#apply!' do
    let!(:school) { create(:school, computacenter_reference: '123456') }
    let!(:allocation) { create(:school_device_allocation, school: school, device_type: 'std_device') }

    before do
      allow(School).to receive(:find_by_computacenter_reference!).with('123456').and_return(school)
      allow(school.device_allocations).to receive(:find_by_device_type!).with('std_device').and_return(allocation)
    end

    it 'finds a school with computacenter_reference matching the ship_to' do
      update.apply!
      expect(School).to have_received(:find_by_computacenter_reference!).with('123456')
    end

    it 'finds the device allocation with the corresponding device_type' do
      update.apply!
      expect(school.device_allocations).to have_received(:find_by_device_type!)
    end

    context 'if the given cap_amount does not match the stored allocation' do
      before do
        update.cap_amount += 1
        allow(update).to receive(:log_cap_mismatch).with(allocation)
      end

      it 'logs a cap mismatch' do
        update.apply!
        expect(update).to have_received(:log_cap_mismatch).with(allocation)
      end
    end

    context 'when no errors are raised' do
      it 'sets the status to "succeeded"' do
        update.apply!
        expect(update.status).to eq('succeeded')
      end
    end
  end
end
