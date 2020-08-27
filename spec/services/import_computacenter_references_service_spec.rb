require 'rails_helper'

describe ImportComputacenterReferencesService do
  let(:csv_content) do
    <<~CSV
      Responsible Body URN,School URN + School Name,School Name (overflow),Address Line 1,Address Line 2 ,Address Line 3,Town/City,Postcode,Ship To Number,Sold To Number
      LEA901,100005 Example school 1,,49 Some Square,,,London,WC1N 2NY,SHIP_TO_1,SOLD_TO_1
      LEA902,100006 Example school 2,,A Road,,,London,NW3 2NY,SHIP_TO_2,SOLD_TO_2
      LEA902,100020 Example school 3,,Some Road,,,London,NW1 8JL,SHIP_TO_3,SOLD_TO_2
      LEA902,100022 Non-existent school,,Some Road,,,London,NW1 8JL,SHIP_TO_4,SOLD_TO_2
      t90003,100023 Example academy,,Some Road,,,London,NW1 8JL,SHIP_TO_A3,SOLD_TO_3
    CSV
  end
  let(:tmp_csv_file) { Tempfile.new }
  let!(:local_authority_2) { create(:local_authority, gias_id: '902') }
  let!(:school_2) { create(:school, name: 'Example school 2', responsible_body: local_authority_2, urn: '100006') }
  let!(:trust_3) { create(:trust, companies_house_number: '00090003') }
  let!(:academy_3) { create(:school, :academy, name: 'Example academy', responsible_body: trust_3, urn: '100023') }

  before do
    tmp_csv_file << csv_content
    tmp_csv_file.flush
  end

  subject(:importer) { ImportComputacenterReferencesService.new(csv_uri: tmp_csv_file.path) }

  describe 'import' do
    before do
      importer.import
    end

    it 'updates the computacenter_reference on any matched ResponsibleBodies' do
      expect(local_authority_2.reload.computacenter_reference).to eq('SOLD_TO_2')
      expect(trust_3.reload.computacenter_reference).to eq('SOLD_TO_3')
    end

    it 'updates the computacenter_reference on any matched Schools' do
      expect(school_2.reload.computacenter_reference).to eq('SHIP_TO_2')
      expect(academy_3.reload.computacenter_reference).to eq('SHIP_TO_A3')
    end

    it 'stores any failures' do
      expect(importer.failures.size).to eq(3)
    end
  end
end
