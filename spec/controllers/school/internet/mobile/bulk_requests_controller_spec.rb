require 'rails_helper'

RSpec.describe School::Internet::Mobile::BulkRequestsController, type: :controller do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  context 'when authenticated' do
    before do
      sign_in_as user
    end

    describe '#new' do
      context 'when school.hide_mno?' do
        let(:school) { create(:school, hide_mno: true) }
        let(:user) { create(:school_user, schools: [school]) }

        it 'returns 404' do
          get :new, params: { urn: school.urn }
          expect(response).to be_not_found
        end
      end
    end

    describe '#create' do
      let(:upload) { Rack::Test::UploadedFile.new(file_fixture('extra-mobile-data-requests.xlsx'), Mime[:xlsx]) }
      let(:request_data) { { urn: school.urn, bulk_upload_form: { upload: upload } } }

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
