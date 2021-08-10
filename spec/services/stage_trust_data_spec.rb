require 'rails_helper'

RSpec.describe StageTrustData, type: :model do
  describe 'importing trusts' do
    let(:filename) { Rails.root.join('tmp/trust_test_data.csv') }
    let(:now) { Time.zone.now }
    let(:number_of_rows) { rand(1..5) }
    let(:attrs) { attributes_for_list(:staged_trust, number_of_rows) }
    let(:service) { described_class.new(TrustDataFile.new(filename)) }
    let(:trust_upsert_service) { instance_double(TrustUpsertService, call: true) }
    let(:trust_data_update_record) { DataStage::DataUpdateRecord.trusts.first }

    before do
      create_trust_csv_file(filename, attrs)
      class_spy(TrustUpsertService, new: trust_upsert_service).as_stubbed_const
      Timecop.freeze(now)
      service.import_trusts
    end

    after do
      Timecop.return
      remove_file(filename)
    end

    it 'upserts records for the trusts imported' do
      expect(trust_upsert_service).to have_received(:call).exactly(number_of_rows).times
    end

    it 'updates trusts staging time' do
      expect(trust_data_update_record.staged_at).to eq(now)
    end
  end
end
