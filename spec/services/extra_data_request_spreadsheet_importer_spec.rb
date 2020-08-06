require 'rails_helper'

RSpec.describe ExtraDataRequestSpreadsheetImporter, type: :model do
  let(:user) { create(:local_authority_user) }
  let(:file) { file_fixture('extra-mobile-data-requests.xlsx') }
  let(:importer) { described_class.new }

  before do
    ActiveJob::Base.queue_adapter = :test
    ['EE', 'O2', 'Tesco Mobile', 'Virgin Mobile', 'Three'].each do |brand|
      create(:mobile_network, brand: brand)
    end
  end

  after do
    ActiveJob::Base.queue_adapter = :inline
  end

  it 'imports valid requests from a spreadsheet' do
    expect {
      importer.import!(file, user)
    }.to change { ExtraMobileDataRequest.count }.by(4)
  end

  it 'queues a SMS notification for the valid request account holders' do
    expect {
      importer.import!(file, user)
    }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob).exactly(4).times
  end
end
