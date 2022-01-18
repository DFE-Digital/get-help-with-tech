require 'rails_helper'

RSpec.describe Support::BulkAllocationForm, type: :model do
  it { is_expected.to validate_presence_of(:upload).with_message('Select a CSV to upload') }

  describe '#save' do
    let(:file) { fixture_file_upload('allocation_upload.csv', 'text/csv') }

    context 'when the form is not valid' do
      subject { described_class.new.save }

      it { is_expected.to be_falsey }
    end

    context 'when the file is not a valid .csv file' do
      subject { described_class.new(upload: 'nofile.csv', send_notification: true).save }

      it { is_expected.to be_falsey }
    end

    it 'enqueue a BulkAlocationJob to process the file' do
      form = described_class.new(upload: file, send_notification: false)
      filename = "tranche-#{form.batch_id}.csv"
      stub_file_storage(file)

      expect {
        form.save
      }.to have_enqueued_job(BulkAllocationJob)
             .with(hash_including(filename: filename, batch_id: form.batch_id, send_notification: false))
             .once
    end
  end
end
