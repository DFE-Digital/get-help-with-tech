require 'rails_helper'

RSpec.describe BulkAllocationJob do
  let(:attrs) do
    [
      {
        urn: '123456',
        ukprn: nil,
        allocation_delta: 1,
        applied_allocation_delta: nil,
        order_state: 'can_order',
        send_notification: true,
        sent_notification: false,
        processed: false,
      },
      {
        urn: nil,
        ukprn: 12_345_678,
        allocation_delta: 2,
        applied_allocation_delta: nil,
        order_state: 'cannot_order',
        send_notification: true,
        sent_notification: false,
        processed: false,
      },
      {
        urn: '345678',
        ukprn: nil,
        allocation_delta: 3,
        applied_allocation_delta: nil,
        order_state: 'can_order',
        send_notification: true,
        sent_notification: false,
        processed: false,
      },
      {
        urn: '999999',
        ukprn: nil,
        allocation_delta: 4,
        applied_allocation_delta: nil,
        order_state: 'can_order',
        send_notification: true,
        sent_notification: false,
        processed: false,
      },
    ]
  end
  let(:batch_id) { SecureRandom.uuid }
  let(:rb) { create(:trust, :vcap, :manages_centrally) }

  before do
    stub_computacenter_outgoing_api_calls(response_body: '', response_status: 200)
  end

  describe '#perform' do
    let(:file) { Rails.root.join('spec/fixtures/files/allocation_upload.csv') }
    let(:filename) { "tranche-#{batch_id}.csv" }

    before do
      stub_file_storage(file)
    end

    it 'creates an AllocationBatchJob per row with allocation_delta set' do
      create(:school, urn: 123_456)
      create(:school, ukprn: 12_345_678)

      expect(AllocationBatchJob.count).to eq(0)
      described_class.perform_now(batch_id:, filename:, send_notification: true)

      AllocationBatchJob.order(:allocation_delta).first(2).each_with_index do |job, i|
        expect(job.attributes.symbolize_keys.except(:created_at, :updated_at, :id, :batch_id)).to eq(attrs[i])
        expect(job.batch_id).to eq(batch_id)
      end
    end

    it 'creates an AllocationBatchJob per row with allocation priorising allocation_delta' do
      create(:school, urn: 345_678, laptops: [2, 0, 0, 0])
      create(:school, urn: 999_999, laptops: [2, 0, 0, 0])

      expect(AllocationBatchJob.count).to eq(0)
      described_class.perform_now(batch_id:, filename:, send_notification: true)

      AllocationBatchJob.order(:allocation_delta).last(2).each_with_index do |job, i|
        expect(job.attributes.symbolize_keys.except(:created_at, :updated_at, :id, :batch_id)).to eq(attrs.last(2)[i])
        expect(job.batch_id).to eq(batch_id)
      end
    end

    it 'enqueue an AllocationJob per non vcap AllocationBatchJob created' do
      create(:school, urn: 123_456)
      create(:school, ukprn: 12_345_678)

      expect {
        described_class.perform_now(batch_id:, filename:, send_notification: true)
      }.to have_enqueued_job(AllocationJob).twice
    end

    it 'enqueue no AllocationJob per vcap AllocationBatchJob created' do
      create(:school, :centrally_managed, responsible_body: rb, urn: 123_456)
      create(:school, :centrally_managed, responsible_body: rb, ukprn: 12_345_678)

      expect {
        described_class.perform_now(batch_id:, filename:, send_notification: false)
      }.not_to have_enqueued_job(AllocationJob)
    end

    it 'enqueue a CalculateVcapJob per vcap' do
      create(:school, :centrally_managed, responsible_body: rb, urn: 123_456)
      create(:school, :centrally_managed, responsible_body: rb, ukprn: 12_345_678)

      expect {
        described_class.perform_now(batch_id:, filename:, send_notification: false)
      }.to have_enqueued_job(CalculateVcapJob)
             .with(hash_including(responsible_body_id: rb.id, notify_school: false))
             .once
    end
  end
end
