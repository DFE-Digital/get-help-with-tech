require 'rails_helper'

RSpec.describe Support::Schools::Devices::OrderStatusController do
  let(:support_user) { create(:support_user) }

  before do
    sign_in_as support_user
  end

  describe '#allow_ordering_for_many_schools' do
    it 'calls import service' do
      importer = instance_double(Importers::AllocationUploadCsv, batch_id: 123)
      allow(Importers::AllocationUploadCsv).to receive(:new).and_return(importer)
      allow(importer).to receive(:call)

      file = fixture_file_upload('allocation_upload.csv', 'text/csv')

      put :allow_ordering_for_many_schools, params: {
        support_bulk_allocation_form: {
          upload: file,
          send_notification: 'false',
        },
      }

      expect(Importers::AllocationUploadCsv).to have_received(:new).with(path_to_csv: anything, send_notification: false)
      expect(importer).to have_received(:call)
    end
  end

  it 'can send notifications' do
    importer = instance_double(Importers::AllocationUploadCsv, batch_id: 123)
    allow(Importers::AllocationUploadCsv).to receive(:new).and_return(importer)
    allow(importer).to receive(:call)

    file = fixture_file_upload('allocation_upload.csv', 'text/csv')

    put :allow_ordering_for_many_schools, params: {
      support_bulk_allocation_form: {
        upload: file,
        send_notification: 'true',
      },
    }

    expect(Importers::AllocationUploadCsv).to have_received(:new).with(path_to_csv: anything, send_notification: true)
    expect(importer).to have_received(:call)
  end
end
