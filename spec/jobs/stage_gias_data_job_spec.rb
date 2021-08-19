require 'rails_helper'

RSpec.describe StageGiasDataJob, type: :job do
  describe '#perform' do
    context 'gias paused', with_feature_flags: { gias_data_stage_pause: 'active' } do
      before do
        allow(StageSchoolData).to receive(:new)
      end

      it 'does NOT call any gias staging code' do
        described_class.perform_now

        expect(StageSchoolData).not_to have_received(:new)
      end
    end

    context 'gias NOT paused', with_feature_flags: { gias_data_stage_pause: 'inactive' } do
      let(:service) { instance_double(StageSchoolData) }

      before do
        allow(service).to receive(:import_schools).and_return(nil)
        allow(service).to receive(:import_school_links).and_return(nil)
        allow(StageSchoolData).to receive(:new).and_return(service)
      end

      it 'calls gias staging code' do
        described_class.perform_now

        expect(service).to have_received(:import_schools)
        expect(service).to have_received(:import_school_links)
      end
    end
  end
end
