require 'rails_helper'

RSpec.describe BatchJob do
  let(:records) { create_list(:local_authority, 3) }
  let(:job) { BatchJob.new(records:, job_name: 'my job') }

  describe '#process!' do
    context 'given a block' do
      it 'yields each record to the block' do
        yielded_records = []
        job.process! { |record| yielded_records << record }
        expect(yielded_records).to eq(records)
      end

      context 'when the block does not raise an error for a record' do
        before do
          job.process! { |_| 'do nothing' }
        end

        it 'adds a BatchJobLogEntry for the record to successes' do
          expect(job.successes.size).to eq(records.size)
          expect(job.successes).to all(be_a(BatchJobLogEntry))
        end

        describe 'each BatchJobLogEntry' do
          it 'identifies the job' do
            expect(job.successes).to all(have_attributes(job_name: 'my job', run_id: job.run_id))
          end

          it 'identifies the record' do
            expect(job.successes).to all(have_attributes(record_class: 'LocalAuthority'))
            expect(job.successes.map { |s| s.record_id.to_i }.sort).to eq(records.map(&:id).sort)
          end

          it 'has status of success' do
            expect(job.successes.map(&:status)).to all(eq('success'))
          end
        end
      end

      context 'when the block raises an error for a record' do
        let(:result) do
          job.process! { |_| raise 'fail!' }
        end

        it 'does not let the error bubble out' do
          expect { result }.not_to raise_error
        end

        it 'adds a BatchJobLogEntry for the record to failures' do
          result
          expect(job.failures.size).to eq(records.size)
          expect(job.failures).to all(be_a(BatchJobLogEntry))
        end

        describe 'each BatchJobLogEntry' do
          before { result }

          it 'identifies the job' do
            expect(job.failures).to all(have_attributes(job_name: 'my job', run_id: job.run_id))
          end

          it 'identifies the record' do
            expect(job.failures).to all(have_attributes(record_class: 'LocalAuthority'))
            expect(job.failures.map { |s| s.record_id.to_i }.sort).to eq(records.map(&:id).sort)
          end

          it 'records the error' do
            expect(job.failures.map(&:error)).to all(eq('fail!'))
          end

          it 'has status of success' do
            expect(job.failures.map(&:status)).to all(eq('failure'))
          end
        end
      end

      it 'returns statistics on completion' do
        result = job.process! { |_| 'processing record' }
        expect(result.keys).to include(:success, :failure, :number_of_records, :duration, :max_created_at, :min_created_at, :records_per_second, :time_per_record)
      end
    end
  end
end
