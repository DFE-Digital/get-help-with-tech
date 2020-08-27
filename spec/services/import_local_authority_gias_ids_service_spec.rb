require 'rails_helper'

describe ImportLocalAuthorityGiasIdsService do
  let(:csv_content) {
    <<~CSV
    Local Authority GIAS ID,Local Authority Name,Address Line 1,Address Line 2,Address Line 3,Town/City,Postcode,Local Authority ENG
    991,City of Test 1,"PO Box 270, Guildhall",,,London,EC2P 2EJ,TST1
    992,Test council 2,218 Eversholt Street,,,London,NW1 1PB,TST2
    993,Test council 3,Woolwich Centre,35 Wellington Street,,London,SE18 6HQ,TST3
    CSV
  }
  let(:tmp_csv_file) { Tempfile.new }
  let!(:test_la_1) { create(:local_authority, local_authority_eng: 'TST1') }
  let!(:test_la_2) { create(:local_authority, local_authority_eng: 'TST2') }

  before do
    tmp_csv_file << csv_content
    tmp_csv_file.flush
  end

  subject(:importer) { ImportLocalAuthorityGiasIdsService.new(csv_uri: tmp_csv_file.path) }

  describe '#import' do
    before do
      importer.import
    end

    it 'updates the GIAS IDs on any LAs with matching ENG' do
      expect( test_la_1.reload.gias_id ).to eq('991')
      expect( test_la_2.reload.gias_id ).to eq('992')
    end

    it 'stores any failed rows' do
      expect(importer.failures.size).to eq(1)
    end
  end
end
