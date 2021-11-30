require 'rails_helper'

RSpec.describe Support::BulkAllocationForm, type: :model do
  it { is_expected.to validate_presence_of(:upload).with_message('Select a CSV to upload') }

  describe '#save' do
    let(:file) { fixture_file_upload('allocation_upload.csv', 'text/csv') }
    let(:rb) { create(:trust, :vcap, :manages_centrally) }
    let(:attrs) do
      [
        {
          urn: '123456',
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
        {
          urn: nil,
          ukprn: 345_678,
          allocation_delta: 3,
          order_state: 'can_order',
          send_notification: true,
          sent_notification: false,
          processed: false,
        },
        {
          urn: nil,
          ukprn: 999,
          allocation_delta: 4,
          order_state: 'can_order',
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

    it 'creates an AllocationBatchJob per row with allocation_delta set' do
      create(:school, urn: 123_456)
      create(:school, ukprn: 12_345_678)

      expect(AllocationBatchJob.count).to eq(0)
      expect(described_class.new(upload: file, send_notification: true).save).to be_truthy

      AllocationBatchJob.order(:allocation_delta).first(2).each_with_index do |job, i|
        expect(job.attributes.symbolize_keys.except(:created_at, :updated_at, :id, :batch_id)).to eq(attrs[i])
        expect(job.batch_id).to be_present
      end
    end

    it 'creates an AllocationBatchJob per row with allocation priorising allocation_delta' do
      create(:school, urn: 345_678, laptops: [2, 0, 0, 0])
      create(:school, urn: 999_999, laptops: [2, 0, 0, 0])

      expect(AllocationBatchJob.count).to eq(0)
      expect(described_class.new(upload: file, send_notification: true).save).to be_truthy

      AllocationBatchJob.order(:allocation_delta).last(2) do |job, i|
        expect(job.attributes.symbolize_keys.except(:created_at, :updated_at, :id, :batch_id)).to eq(attrs.last(2)[i])
        expect(job.batch_id).to be_present
      end
    end

    it 'enqueue an AllocationJob per non vcap AllocationBatchJob created' do
      create(:school, urn: 123_456)
      create(:school, ukprn: 12_345_678)

      expect {
        described_class.new(upload: file, send_notification: true).save
      }.to have_enqueued_job(AllocationJob).twice
    end

    it 'enqueue no AllocationJob per vcap AllocationBatchJob created' do
      create(:school, :centrally_managed, responsible_body: rb, urn: 123_456)
      create(:school, :centrally_managed, responsible_body: rb, ukprn: 12_345_678)

      expect {
        described_class.new(upload: file, send_notification: true).save
      }.not_to have_enqueued_job(AllocationJob)
    end

    it 'enqueue a CalculateVcapJob per vcap' do
      create(:school, :centrally_managed, responsible_body: rb, urn: 123_456)
      create(:school, :centrally_managed, responsible_body: rb, ukprn: 12_345_678)

      expect {
        described_class.new(upload: file, send_notification: true).save
      }.to have_enqueued_job(CalculateVcapJob)
             .with(hash_including(responsible_body_id: rb.id, notify_school: true))
             .once
    end
  end
end
