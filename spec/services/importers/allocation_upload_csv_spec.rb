require 'rails_helper'
require 'tempfile'

RSpec.describe Importers::AllocationUploadCsv do
  subject(:service) { described_class.new(path_to_csv: file.path) }

  let(:school) { create(:school) }

  let(:csv_payload) do
    <<~CSV
      urn,ukprn,allocation_delta,order_state
    CSV
  end

  describe '#call' do
    let(:file) { Tempfile.new }

    before do
      csv_payload << "#{school.urn},#{school.ukprn},3,can_order"
      file.write(csv_payload)
      file.close
    end

    after do
      file.unlink
    end

    it 'persists records to db' do
      expect {
        service.call
      }.to change(AllocationBatchJob, :count).by(1)

      record = AllocationBatchJob.last
      expect(record.urn).to eql(school.urn)
      expect(record.ukprn).to eql(school.ukprn)
      expect(record.allocation_delta).to be(3)
      expect(record.order_state).to eql('can_order')

      expect(record.batch_id).to be_present
      expect(record.sent_notification).to be_falsey
      expect(record.processed).to be_falsey
    end
  end
end
