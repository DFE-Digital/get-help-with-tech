require 'rails_helper'

RSpec.shared_examples 'a user change request' do |feature_flags|
  let(:user_change) { create(:user_change, :school_user) }
  let(:request) { described_class.new(user_change: user_change) }

  let(:response_body) do
    <<~JSON
      {
        "import_set": "ISET0010250",
        "staging_table": "u_dfe_users_import",
        "result": [
          {
            "transform_map": "DFE Users Import TM",
            "table": "sys_user",
            "display_name": "name",
            "display_value": "Test User",
            "record_link": "https://computacentertest.service-now.com/api/now/table/sys_user/b5adecb5db1b1c10e39ba1ea4b96198b",
            "status": "inserted",
            "sys_id": "b5adecb5db1b1c10e39ba1ea4b96198b",
            "status_message": "Unable to find Sold to with ID provided 1"
          }
        ]
      }
    JSON
  end
  let(:mock_status) { instance_double(HTTP::Response::Status, code: 200, success?: true) }
  let(:mock_response) { instance_double(HTTP::Response, status: mock_status, body: response_body) }

  before do
    allow(Settings.computacenter.service_now_user_import_api).to receive(:endpoint).and_return 'http://example.com/import/table'
    stub_request(:post, Settings.computacenter.service_now_user_import_api.endpoint).to_return(status: 201, body: response_body)
  end

  describe '#post!', with_feature_flags: feature_flags do
    it 'POSTs the body to the endpoint using Basic Auth' do
      allow(HTTP).to receive(:basic_auth).and_return(HTTP)
      allow(HTTP).to receive(:post).and_return(mock_response)

      request.post!
      expect(HTTP).to have_received(:basic_auth).with(user: request.username, pass: request.password)
      expect(HTTP).to have_received(:post).with(request.endpoint, body: expected_json)
    end

    it 'generates a correct body' do
      request.timestamp = Time.new(2020, 9, 2, 15, 3, 35, '+02:00')
      request.post!
      expect(a_request(:post, request.endpoint).with(body: expected_json)).to have_been_made
    end

    context 'for different types of update' do
      before do
        request.timestamp = Time.new(2020, 9, 2, 15, 3, 35, '+02:00')
        request.post!
      end

      context 'when the type_of_update is New' do
        let(:user_change) { create(:user_change, :school_user, type_of_update: 'New') }

        it 'generates a correct body' do
          expect(a_request(:post, request.endpoint).with(body: expected_json)).to have_been_made
        end
      end

      context 'when the type_of_update is Change' do
        let(:user_change) { create(:user_change, :school_user, type_of_update: 'Change') }

        it 'generates a correct body' do
          expect(a_request(:post, request.endpoint).with(body: expected_json)).to have_been_made
        end
      end

      context 'when the type_of_update is Remove' do
        let(:user_change) { create(:user_change, :school_user, type_of_update: 'Remove') }

        it 'generates a correct body' do
          expect(a_request(:post, request.endpoint).with(body: expected_json)).to have_been_made
        end
      end
    end

    context 'when the response status is success' do
      let(:mock_status) { instance_double(HTTP::Response::Status, code: 200, success?: true) }

      it 'returns the response ' do
        expect(request.post!).to be_a(HTTP::Response)
      end
    end

    context 'when the response status is not a success' do
      let(:mock_status) { instance_double(HTTP::Response::Status, code: 401, success?: false) }

      before do
        allow(HTTP).to receive(:basic_auth).and_return(HTTP)
        allow(HTTP).to receive(:post).and_return(mock_response)
      end

      it 'raises an error' do
        expect { request.post! }.to raise_error(Computacenter::ServiceNowUserImportAPI::Error)
      end
    end

    context 'when the response contains an error' do
      let(:response_body) do
        <<~BODY
          {
            "import_set":"ISET0010261",
            "staging_table":"u_dfe_users_import",
            "result":[
              {
                "transform_map":"DFE Users Import TM",
                "table":"sys_user",
                "status":"error",
                "error_message":"Target record not found",
                "status_message":"Row transform ignored by onBefore script","validation_message":"Sold To Number [u_cc_sold_to_number] not provided - record ignored"
              }
            ]
          }
        BODY
      end

      before do
        allow(HTTP).to receive(:basic_auth).and_return(HTTP)
        allow(HTTP).to receive(:post).and_return(mock_response)
      end

      it 'raises an error' do
        expect { request.post! }.to raise_error(Computacenter::ServiceNowUserImportAPI::Error)
      end
    end

    context 'when the response does not contain an error' do
      let(:response_body) do
        <<~JSON
          {
             "import_set": "ISET0010250",
             "staging_table": "u_dfe_users_import",
             "result": [
               {
                 "transform_map": "DFE Users Import TM",
                 "table": "sys_user",
                 "display_name": "name",
                 "display_value": "Test User",
                 "record_link": "https://computacentertest.service-now.com/api/now/table/sys_user/b5adecb5db1b1c10e39ba1ea4b96198b",
                 "status": "inserted",
                 "sys_id": "b5adecb5db1b1c10e39ba1ea4b96198b",
                 "status_message": "some message here"
               }
             ]
           }
        JSON
      end

      before do
        allow(HTTP).to receive(:basic_auth).and_return(HTTP)
        allow(HTTP).to receive(:post).and_return(mock_response)
      end

      it 'does not raise an error' do
        expect { request.post! }.not_to raise_error
      end
    end
  end

  def expected_json
    attrs = {
      u_email: user_change.email_address,
      u_type_of_update: user_change.type_of_update,
      u_cc_sold_to_number: user_change.cc_sold_to_number,
      u_first_name: user_change.first_name,
      u_last_name: user_change.last_name,
      u_responsible_body: user_change.responsible_body,
      u_responsible_body_urn: user_change.responsible_body_urn,
      u_cc_ship_to_number: user_change.cc_ship_to_number,
      u_date_of_update: user_change.updated_at_timestamp.utc.strftime('%d/%m/%Y'),
      u_school: user_change.school,
      u_school_urn: user_change.school_urn,
      u_telephone: user_change.telephone,
      u_timestamp_of_update: user_change.updated_at_timestamp.utc.iso8601,
      u_time_of_update: user_change.updated_at_timestamp.utc.strftime('%R %z'),
      u_original_email: user_change.original_email_address,
      u_original_cc_sold_to_number: user_change.original_cc_sold_to_number,
      u_original_first_name: user_change.original_first_name,
      u_original_last_name: user_change.original_last_name,
      u_original_responsible_body: user_change.original_responsible_body,
      u_original_responsible_body_urn: user_change.original_responsible_body_urn,
      u_original_cc_ship_to_number: user_change.original_cc_ship_to_number,
      u_original_school: user_change.original_school,
      u_original_school_urn: user_change.original_school_urn,
      u_original_telephone: user_change.original_telephone,
    }

    if FeatureFlag.active?(:rb_level_access_notification)
      attrs.merge!({
        u_rb_user: user_change.cc_rb_user,
        u_original_rb_user: user_change.original_cc_rb_user,
      })
    end

    attrs.to_json
  end
end

RSpec.describe Computacenter::ServiceNowUserImportAPI::ImportUserChangeRequest do
  it_behaves_like 'a user change request', { rb_level_access_notification: 'active' }
  it_behaves_like 'a user change request', { rb_level_access_notification: 'inactive' }
end
