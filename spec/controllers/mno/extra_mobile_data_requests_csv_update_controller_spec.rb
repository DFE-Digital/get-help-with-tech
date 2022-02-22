require 'rails_helper'

describe Mno::ExtraMobileDataRequestsCsvUpdateController, type: :controller do
  let(:mno_user) { create(:mno_user) }
  let(:local_authority_user) { create(:local_authority_user) }
  let(:filename) { Rails.root.join('tmp/update_status.csv') }
  let(:requests) { create_list(:extra_mobile_data_request, 2, mobile_network: mno_user.mobile_network, created_by_user: local_authority_user) }

  before do
    sign_in_as mno_user
  end

  describe 'POST create' do
    before do
      attrs = requests_to_attrs
      create_extra_mobile_data_request_update_csv_file(filename, attrs)
    end

    it 'accepts the standard content-type for csv' do
      upload = Rack::Test::UploadedFile.new(filename, 'text/csv')

      post :create, params: { mno_csv_status_update_form: { upload: } }
      expect(response).to render_template(:summary)
    end

    it 'accepts Microsofts content-type for csv' do
      upload = Rack::Test::UploadedFile.new(filename, 'application/vnd.ms-excel')

      post :create, params: { mno_csv_status_update_form: { upload: } }
      expect(response).to render_template(:summary)
    end

    it 'accepts a valid CSV file in UTF8 character encoding' do
      upload = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/extra-mobile-data-request-utf8.csv'), 'text/csv')

      post :create, params: { mno_csv_status_update_form: { upload: } }
      expect(response).to render_template(:summary)
    end

    it 'accepts a valid CSV file in Windows-1252 character encoding' do
      upload = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/extra-mobile-data-request-windows-1252.csv'), 'application/vnd.ms-excel')

      post :create, params: { mno_csv_status_update_form: { upload: } }
      expect(response).to render_template(:summary)
    end
  end

  def requests_to_attrs
    requests.map do |req|
      {
        id: req.id,
        account_holder_name: req.account_holder_name,
        device_phone_number: req.device_phone_number,
        created_at: req.created_at,
        updated_at: req.updated_at,
        mobile_network_id: req.mobile_network_id,
        status: req.status,
        contract_type: req.contract_type,
      }
    end
  end
end
