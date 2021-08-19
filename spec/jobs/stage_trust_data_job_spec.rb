require 'rails_helper'

RSpec.describe StageTrustDataJob, type: :job do
  describe '#perform' do
    context 'gias paused', with_feature_flags: { gias_data_stage_pause: 'active' } do
      before do
        allow(StageTrustData).to receive(:new)
      end

      it 'does NOT call any gias staging code' do
        described_class.perform_now

        expect(StageTrustData).not_to have_received(:new)
      end
    end

    context 'gias NOT paused', with_feature_flags: { gias_data_stage_pause: 'inactive' } do
      let(:service) { instance_double(StageTrustData) }

      before do
        allow(service).to receive(:import_trusts).and_return(nil)
        allow(StageTrustData).to receive(:new).and_return(service)
      end

      it 'calls gias staging code' do
        described_class.perform_now

        expect(service).to have_received(:import_trusts)
      end
    end
  end
end
