require 'rails_helper'

RSpec.describe Computacenter::CapTypeConverter do
  describe '.to_dfe_type' do
    context 'given a valid computacenter capType' do
      it 'returns the correct device_type' do
        expect(Computacenter::CapTypeConverter.to_dfe_type('DfE_RemainThresholdQty|Std_Device')).to eq(:laptop)
        expect(Computacenter::CapTypeConverter.to_dfe_type('DfE_RemainThresholdQty|Coms_Device')).to eq(:router)
      end
    end

    context 'given an invalid computacenter capType' do
      it 'returns nil' do
        expect(Computacenter::CapTypeConverter.to_dfe_type('Some|Incorrect_Device_Type')).to be_nil
      end
    end
  end

  describe '.to_computacenter_type' do
    context 'given a valid DfE device_type' do
      it 'returns the correct computacenter capType' do
        expect(Computacenter::CapTypeConverter.to_computacenter_type(:laptop)).to eq('DfE_RemainThresholdQty|Std_Device')
        expect(Computacenter::CapTypeConverter.to_computacenter_type(:router)).to eq('DfE_RemainThresholdQty|Coms_Device')
      end
    end

    context 'given an invalid DfE device_type' do
      it 'returns nil' do
        expect(Computacenter::CapTypeConverter.to_computacenter_type('???')).to be_nil
      end
    end
  end
end
