require 'rails_helper'

RSpec.describe Support::BulkAllocationForm, type: :model do
  it { is_expected.to validate_presence_of(:upload).with_message('Select a CSV to upload') }

  describe '#save' do
    let(:file) { fixture_file_upload('allocation_upload.csv', 'text/csv') }
    let(:attrs) do
      [
        {
          urn: 123_456,
          ukprn: nil,
          allocation_delta: 1,
          order_state: 'can_order',
          send_notification: true,
          sent_notification: false,
          processed: false,
        },
        {
          urn: nil,
          ukprn: 12_345_678,
          allocation_delta: 2,
          order_state: 'cannot_order',
          send_notification: true,
          sent_notification: false,
          processed: false,
        },
      ]
    end

    context 'when the form is not valid' do
      subject { described_class.new.save }

      it { is_expected.to be_falsey }
    end

    context 'when the file is not a valid .csv file' do
      subject { described_class.new(upload: 'nofile.csv', send_notification: true).save }

      it { is_expected.to be_falsey }
    end

    it 'creates an AllocationBatchJob per row in the file' do
      expect(AllocationBatchJob.count).to eq(0)

      expect(described_class.new(upload: file, send_notification: true).save).to be_truthy

      AllocationBatchJob.order(:allocation_delta).to_a.each_with_index do |job, i|
        expect(job.attributes.symbolize_keys.except(:created_at, :updated_at, :id, :batch_id)).to eq(attrs[i])
        expect(job.batch_id).to be_present
      end
    end

    it 'enqueue an AllocationJob per AllocationBatchJob created' do
      expect {
        described_class.new(upload: file, send_notification: true).save
      }.to have_enqueued_job(AllocationJob).twice
    end
  end
end
