require 'rails_helper'

RSpec.describe ResponsibleBody::Internet::Mobile::BulkRequestsController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }

  context 'when authenticated' do
    before do
      sign_in_as local_authority_user
    end

    describe 'create' do
      let(:upload) { Rack::Test::UploadedFile.new(file_fixture('extra-mobile-data-requests.xlsx'), Mime[:xlsx]) }
      let(:request_data) { { bulk_upload_form: { upload: upload } } }

      before do
        ['EE', 'O2', 'Tesco Mobile', 'Virgin Mobile', 'Three'].each do |brand|
          create(:mobile_network, brand: brand)
        end
      end

      it 'sends an sms to the account holder of each valid request in the spreadsheet' do
        # file has 4 valid requests, 1 invalid
        expect {
          post :create, params: request_data
        }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob).exactly(4).times
      end
    end
  end
end
