require 'rails_helper'

RSpec.describe ExtraDataRequestSpreadsheetImporter, type: :model do
  let(:user) { create(:local_authority_user) }
  let(:rb) { user.responsible_body }
  let(:file) { file_fixture('extra-mobile-data-requests.xlsx') }
  let(:spreadsheet) { ExtraMobileDataRequestSpreadsheet.new(path: file) }
  let(:importer) { described_class.new(spreadsheet) }

  before do
    ['EE', 'O2', 'Tesco Mobile', 'Virgin Mobile', 'SMARTY', 'Three'].each do |brand|
      create(:mobile_network, brand: brand)
    end
  end

  it 'imports valid requests from a spreadsheet created in Excel' do
    expect {
      importer.import!(extra_fields: { responsible_body: rb, created_by_user: user })
    }.to change { ExtraMobileDataRequest.count }.by(3)
  end

  context 'when importing a spreadsheet created in Google Docs' do
    let(:file) { file_fixture('extra-mobile-data-requests-google-docs.xlsx') }

    it 'imports valid requests' do
      expect {
        importer.import!(extra_fields: { responsible_body: rb, created_by_user: user })
      }.to change { ExtraMobileDataRequest.count }.by(1)
    end
  end

  it 'sets created_by_user' do
    importer.import!(extra_fields: { responsible_body: rb, created_by_user: user })
    record = ExtraMobileDataRequest.last
    expect(record.created_by_user).to eql(user)
  end

  it 'sets responsible_body' do
    importer.import!(extra_fields: { created_by_user: user, responsible_body: user.responsible_body })
    record = ExtraMobileDataRequest.last
    expect(record.responsible_body).to eql(user.responsible_body)
  end

  it 'queues a SMS notification for the valid request account holders' do
    expect {
      importer.import!(extra_fields: { responsible_body: rb, created_by_user: user })
    }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob).exactly(3).times
  end

  context 'when school.hide_mno is true' do
    let(:school) { create(:school, hide_mno: true) }
    let(:spreadsheet) { OpenStruct.new(requests: requests) }

    let(:requests) do
      [
        {
          account_holder_name: 'John Doe',
          mobile_phone_number: '07123456780',
          mobile_network: MobileNetwork.fe_networks.sample.brand,
          pay_monthly_or_payg: 'pay_monthly',
          has_someone_shared_the_privacy_statement_with_the_account_holder: 'TRUE',
        },
        {
          account_holder_name: 'John Doe',
          mobile_phone_number: '07123456781',
          mobile_network: MobileNetwork.excluded_fe_networks.sample.brand,
          pay_monthly_or_payg: 'pay_monthly',
          has_someone_shared_the_privacy_statement_with_the_account_holder: 'TRUE',
        },
      ].map { |hash| ExtraMobileDataRequestRow.new(hash).build_request }
    end

    before do
      MobileNetwork.all.sample.update(excluded_fe_network: true)
    end

    it 'errors on excluded FE networks' do
      importer.import!(extra_fields: { school: school })
      expect(importer.summary.successful.size).to be(1)
      expect(importer.summary.errors.size).to be(1)
    end
  end
end
