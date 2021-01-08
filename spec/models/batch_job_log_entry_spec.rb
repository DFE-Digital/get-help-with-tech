require 'rails_helper'

RSpec.describe BatchJobLogEntry do
  describe '.status' do
    before do
      BatchJobLogEntry.create!(run_id: '123', status: 'ok')
      BatchJobLogEntry.create!(run_id: '890', status: 'not_ok')
      BatchJobLogEntry.create!(run_id: '123', status: 'not_ok')
    end

    it 'returns a count of status values for all entries with the given run_id' do
      result = BatchJobLogEntry.status(run_id: '123')
      expect(result[:ok]).to eq(1)
      expect(result[:not_ok]).to eq(1)
    end

    it 'includes :success and :failure counts even when there are not records with that status' do
      result = BatchJobLogEntry.status(run_id: '123')
      expect(result[:success]).to eq(0)
      expect(result[:failure]).to eq(0)
    end
  end

  describe '.latest_for_job' do
    before do
      BatchJobLogEntry.create!(job_name: 'my job', run_id: '123', status: 'ok')
      BatchJobLogEntry.create!(job_name: 'my job', run_id: '890', status: 'not_ok')
      BatchJobLogEntry.create!(job_name: 'not my job', run_id: '456', status: 'not_ok')
    end

    context 'when multiple entries are present for the given job_name' do
      it 'returns the latest entry' do
        expect(BatchJobLogEntry.latest_for_job(job_name: 'my job')).to have_attributes(job_name: 'my job', run_id: '890', status: 'not_ok')
      end
    end
  end

  describe '.speed_stats' do
    before do
      BatchJobLogEntry.create!(run_id: '123', status: 'ok')
      BatchJobLogEntry.create!(run_id: '123', status: 'not_ok')
      BatchJobLogEntry.create!(run_id: '123', status: 'not_ok')
      BatchJobLogEntry.create!(run_id: '890', status: 'not_ok')
    end

    let(:result) { BatchJobLogEntry.speed_stats(run_id: '123') }

    it 'is a Hash' do
      expect(result).to be_a(Hash)
    end

    it 'has the number_of_records' do
      expect(result[:number_of_records]).to eq(3)
    end

    it 'has a max_created_at and min_created_at' do
      expect(result.keys).to include(:max_created_at, :min_created_at)
    end

    it 'has correct duration' do
      expect(result[:duration]).to eq(result[:max_created_at] - result[:min_created_at])
    end

    it 'has correct time_per_record' do
      expect(result[:time_per_record]).to eq(result[:duration] / result[:number_of_records])
    end

    it 'has correct records_per_second' do
      expect(result[:records_per_second]).to eq(result[:number_of_records] / result[:duration])
    end
  end
end
