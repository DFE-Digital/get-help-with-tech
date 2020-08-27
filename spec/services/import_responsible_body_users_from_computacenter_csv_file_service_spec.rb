require 'rails_helper'

RSpec.describe ImportResponsibleBodyUsersFromComputacenterCsvService do
  let(:csv_content) do
    <<~CSV
      UserID,Title,First Name,Last Name,Telephone,Email,SoldTos,DefaultSoldto,Default Language,Active,MobileNumber,Guid,,
      a.person@sometrust.co.uk,,Andrea,Person,,a.person@sometrust.co.uk,SOLD_TO_1,SOLD_TO_1,en,TRUE,,536c953b-2a7e-4a3d-8ec5-cfc09cb4d67c,,
      b.someone@aschool.sch.uk,,Brian,Someone,01234 567890,b.someone@aschool.sch.uk,SOLD_TO_2,SOLD_TO_2,en,TRUE,,39404dd9-f579-4e25-997d-440bf3f74815,,
      c.mee@anotherschool.org,,Carole,Mee,,c.mee@anotherschool.org,SOLD_TO_3,SOLD_TO_3,en,TRUE,,ff6083c0-d000-478d-83bb-5cdfe717cd21,,
      d.barkel@alocalauthority.gov.uk,,Dee,Barkel,,d.barkel@alocalauthority.gov.uk,"SOLD_TO_4, SOLD_TO_5, SOLD_TO_6, SOLD_TO_7",SOLD_TO_6,en,TRUE,,5d8f62f3-133f-42bc-8569-f265e94c0021,,
      e.baigum@nowhere.org,,Eric,Baigum,,e.baigum@nowhere.org,NON_EXISTING_SOLD_TO,NON_EXISTING_SOLD_TO,en,TRUE,,ff6083c0-d000-478d-83bb-5cdfe717cd24,,
      x.istinguser@some.sch.uk,,Xavier,Istinguser,,x.istinguser@some.sch.uk,SOLD_TO_3,SOLD_TO_3,en,TRUE,,ff6083c0-d000-478d-83bb-5cdfe717cd25,,
    CSV
  end
  let(:tmp_csv_file) { Tempfile.new }
  let!(:trust) { create(:trust, computacenter_reference: 'SOLD_TO_1') }
  let!(:local_authority_2) { create(:local_authority, computacenter_reference: 'SOLD_TO_2') }
  let!(:local_authority_3) { create(:local_authority, computacenter_reference: 'SOLD_TO_3') }
  let!(:local_authority_4) { create(:local_authority, computacenter_reference: 'SOLD_TO_4') }
  let!(:local_authority_5) { create(:local_authority, computacenter_reference: 'SOLD_TO_5') }
  let!(:existing_user) { create(:local_authority_user, responsible_body: local_authority_3, email_address: 'x.istinguser@some.sch.uk') }

  before do
    tmp_csv_file << csv_content
    tmp_csv_file.flush
  end

  subject(:importer) { ImportResponsibleBodyUsersFromComputacenterCsvService.new(csv_uri: tmp_csv_file.path) }

  describe 'import' do
    before do
      importer.import
    end

    context 'when the DefaultSoldto exists on a ResponsibleBody' do
      it 'creates a User record on the responsible_body for each email address that does not already exist' do
        expect(trust.users.pluck(:email_address)).to eq(['a.person@sometrust.co.uk'])
        expect(local_authority_2.users.pluck(:email_address)).to eq(['b.someone@aschool.sch.uk'])
        expect(local_authority_3.users.pluck(:email_address)).to include('c.mee@anotherschool.org')
      end

      it 'records any existing users as failures' do
        expect(importer.failures.map { |f| f[:row]['Email'] }).to include('x.istinguser@some.sch.uk')
      end
    end

    context 'when the DefaultSoldto does not exist on a ResponsibleBody' do
      it 'assigns the user to the first entry in their SoldTos that matches an RB' do
        expect(User.find_by_email_address!('d.barkel@alocalauthority.gov.uk').responsible_body).to eq(local_authority_4)
      end

      context 'when it cannot match any of the SoldTos to an RB' do
        it 'does not create the user' do
          expect { User.find_by_email_address!('e.baigum@nowhere.org') }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'records the row as a failure' do
          expect(importer.failures.map { |f| f[:row]['Email'] }).to include('e.baigum@nowhere.org')
        end
      end
    end


    it 'stores any failures' do
      expect(importer.failures.size).to eq(2)
    end
  end
end
