require 'rails_helper'

RSpec.describe ResponsibleBody::Internet::Mobile::BulkRequestsController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }
  let(:filename) { Rails.root.join('tmp/update_requests.xlsx') }

  describe '#create' do
    let(:upload) { Rack::Test::UploadedFile.new(file_fixture('extra-mobile-data-requests.xlsx'), Mime[:xlsx]) }
    let(:request_data) { { bulk_upload_form: { upload: upload } } }

    before do
      ['EE', 'O2', 'Tesco Mobile', 'Virgin Mobile', 'Three'].each do |brand|
        create(:mobile_network, brand: brand)
      end
    end

    context 'when authenticated' do
      before do
        sign_in_as local_authority_user
      end

      it 'sends an SMS to the account holder of each valid request in the spreadsheet' do
        # file has 1 example, 3 valid requests, 1 invalid
        expect {
          post :create, params: request_data
        }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob).exactly(3).times
      end

      it 'throws a catch-all error message if something unexpected goes wrong with the import' do
        importer = instance_double(ExtraDataRequestSpreadsheetImporter)
        allow(ExtraDataRequestSpreadsheetImporter).to receive(:new).and_return(importer)
        allow(importer).to receive(:import!).and_raise(StandardError)

        post :create, params: request_data

        expect(response).to have_http_status(:unprocessable_entity)
        expect(assigns[:upload_form].errors.full_messages).to eq(["'Upload' There’s a problem with that spreadsheet"])
      end

      it 'accepts the standard content-type for xlsx' do
        upload = Rack::Test::UploadedFile.new(file_fixture('extra-mobile-data-requests.xlsx'), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

        post :create, params: { bulk_upload_form: { upload: upload } }
        expect(response).to render_template(:summary)
      end

      it 'accepts Chromebooks content-type for xlsx' do
        upload = Rack::Test::UploadedFile.new(file_fixture('extra-mobile-data-requests.xlsx'), 'application/octet-stream')

        post :create, params: { bulk_upload_form: { upload: upload } }
        expect(response).to render_template(:summary)
      end
    end

    context 'when support user impersonating' do
      let(:support_user) { create(:support_user) }

      before do
        sign_in_as support_user
        impersonate local_authority_user
      end

      it 'returns forbidden' do
        post :create, params: request_data
        expect(response).to be_forbidden
      end
    end
  end
end
