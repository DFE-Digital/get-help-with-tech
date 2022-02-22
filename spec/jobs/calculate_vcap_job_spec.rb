require 'rails_helper'

RSpec.describe CalculateVcapJob do
  before do
    stub_computacenter_outgoing_api_calls(response_body: '', response_status: 200)
  end

  describe '#perform' do
    let(:batch_id) { SecureRandom.uuid }
    let(:rb) { create(:trust, :vcap, :manages_centrally) }
    let(:schools) do
      [create(:school, :centrally_managed, responsible_body: rb, laptops: [2, 2, 0], routers: [2, 2, 0]),
       create(:school, :centrally_managed, responsible_body: rb, laptops: [2, 2, 2], routers: [2, 2, 2])]
    end

    let!(:batch_jobs) do
      schools.map do |school|
        create(:allocation_batch_job,
               batch_id:,
               urn: school.urn,
               allocation_delta: 3,
               order_state: :can_order,
               send_notification: true)
      end
    end

    it 'processes all related batch jobs' do
      batch_jobs.each { |batch_job| expect(batch_job.reload).not_to be_processed }

      described_class.perform_now(responsible_body_id: rb.id, batch_id:)

      batch_jobs.each { |batch_job| expect(batch_job.reload).to be_processed }
    end

    it 'update vcap numbers' do
      expect(rb.laptops).to eq([0, 0, 0])
      expect(rb.routers).to eq([0, 0, 0])

      described_class.perform_now(responsible_body_id: rb.id, batch_id:)
      rb.reload

      expect(rb.laptops).to eq([10, 10, 2])
      expect(rb.routers).to eq([4, 4, 2])
    end
  end
end
