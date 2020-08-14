require 'rails_helper'

RSpec.describe Computacenter::API::CapUsageUpdateBatch do
  let(:string_hash) { {} }
  let(:batch) { described_class.new(string_hash) }

  describe '#process!' do
    before do
      batch.updates = %w[update1 update2 update3]
      allow(batch).to receive(:apply_update_and_catch_errors)
    end

    it 'calls apply_update_and_catch_errors with each update' do
      batch.process!
      expect(batch).to have_received(:apply_update_and_catch_errors).with('update1').ordered
      expect(batch).to have_received(:apply_update_and_catch_errors).with('update2').ordered
      expect(batch).to have_received(:apply_update_and_catch_errors).with('update3').ordered
    end
  end

  describe '#apply_update_and_catch_errors' do
    let(:mock_update) { instance_double(Computacenter::API::CapUsageUpdate) }

    before do
      allow(mock_update).to receive(:apply!)
    end

    it 'applies the given update' do
      batch.apply_update_and_catch_errors(mock_update)
      expect(mock_update).to have_received(:apply!)
    end

    context 'when applying the update raises an ActiveRecord::RecordNotFound error' do
      before do
        allow(mock_update).to receive(:apply!).and_raise(ActiveRecord::RecordNotFound, 'my message')
        allow(mock_update).to receive(:fail!)
      end

      it 'does not allow the exception to bubble out' do
        expect { batch.apply_update_and_catch_errors(mock_update) }.not_to raise_error
      end

      it 'calls fail! on the update, passing the error message' do
        batch.apply_update_and_catch_errors(mock_update)
        expect(mock_update).to have_received(:fail!).with 'my message'
      end
    end
  end

  describe 'status' do
    let(:mock_update_1) { instance_double(Computacenter::API::CapUsageUpdate, 'succeeded?': false, 'failed?': false) }
    let(:mock_update_2) { instance_double(Computacenter::API::CapUsageUpdate, 'succeeded?': false, 'failed?': false) }

    before do
      batch.updates = [mock_update_1, mock_update_2]
    end

    context 'when all updates succeeded?' do
      before do
        allow(mock_update_1).to receive(:succeeded?).and_return(true)
        allow(mock_update_2).to receive(:succeeded?).and_return(true)
      end

      it 'returns "succeeded"' do
        expect(batch.status).to eq('succeeded')
      end
    end

    context 'when all updates failed?' do
      before do
        allow(mock_update_1).to receive(:failed?).and_return(true)
        allow(mock_update_2).to receive(:failed?).and_return(true)
      end

      it 'returns "failed"' do
        expect(batch.status).to eq('failed')
      end
    end

    context 'when some but not all updates failed?' do
      before do
        allow(mock_update_1).to receive(:succeeded?).and_return(true)
        allow(mock_update_2).to receive(:failed?).and_return(true)
      end

      it 'returns "partially_failed"' do
        expect(batch.status).to eq('partially_failed')
      end
    end
  end
end
