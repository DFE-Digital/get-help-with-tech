require 'rails_helper'

RSpec.describe School::Internet::Mobile::BulkRequestsController, type: :controller do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  context 'when authenticated' do
    before do
      sign_in_as user
    end

    describe 'create' do
      let(:upload) { Rack::Test::UploadedFile.new(file_fixture('extra-mobile-data-requests.xlsx'), Mime[:xlsx]) }
      let(:request_data) { { urn: school.urn, bulk_upload_form: { upload: upload } } }

      before do
        ['EE', 'O2', 'Tesco Mobile', 'Virgin Mobile', 'Three'].each do |brand|
          create(:mobile_network, brand: brand)
        end
      end

      it 'sends an SMS to the account holder of each valid request in the spreadsheet' do
        # file has 4 valid requests, 1 invalid
        expect {
          post :create, params: request_data
        }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob).exactly(4).times
      end

      it 'throws a catch-all error message if something unexpected goes wrong with the import' do
        importer = instance_double(ExtraDataRequestSpreadsheetImporter)
        allow(ExtraDataRequestSpreadsheetImporter).to receive(:new).and_return(importer)
        allow(importer).to receive(:import!).and_raise(StandardError)

        post :create, params: request_data

        expect(response).to have_http_status(:unprocessable_entity)
        expect(assigns[:upload_form].errors.full_messages).to eq(["'Upload' There’s a problem with that spreadsheet"])
      end
    end
  end
end
