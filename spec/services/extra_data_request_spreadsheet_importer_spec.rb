require 'rails_helper'

RSpec.describe ExtraDataRequestSpreadsheetImporter, type: :model do
  let(:user) { create(:local_authority_user) }
  let(:file) { file_fixture('extra-mobile-data-requests.xlsx') }
  let(:importer) { described_class.new }

  before do
    ['EE', 'O2', 'Tesco Mobile', 'Virgin Mobile', 'Three'].each do |brand|
      create(:mobile_network, brand: brand)
    end
  end

  it 'imports valid requests from a spreadsheet' do
    expect {
      importer.import!(file, extra_fields: { created_by_user: user })
    }.to change { ExtraMobileDataRequest.count }.by(4)
  end

  it 'sets created_by_user' do
    importer.import!(file, extra_fields: { created_by_user: user })
    record = ExtraMobileDataRequest.last
    expect(record.created_by_user).to eql(user)
  end

  it 'sets responsible_body' do
    importer.import!(file, extra_fields: { created_by_user: user, responsible_body: user.responsible_body })
    record = ExtraMobileDataRequest.last
    expect(record.responsible_body).to eql(user.responsible_body)
  end

  it 'queues a SMS notification for the valid request account holders' do
    expect {
      importer.import!(file, extra_fields: { created_by_user: user })
    }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob).exactly(4).times
  end
end
