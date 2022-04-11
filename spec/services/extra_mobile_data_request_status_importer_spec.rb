require 'rails_helper'

RSpec.describe ExtraMobileDataRequestStatusImporter, type: :model do
  let(:user) { create(:local_authority_user) }
  let(:mno) { create(:mobile_network) }
  let(:request) { create(:extra_mobile_data_request, mobile_network: mno) }

  let(:attrs) do
    {
      id: request.id,
      account_holder_name: request.account_holder_name,
      device_phone_number: request.device_phone_number,
      mobile_network_id: request.mobile_network_id,
      status: 'complete',
    }
  end

  let(:filename) { Rails.root.join('tmp/extra-mobile-data-request-update.csv') }
  let(:datasource) { ExtraMobileDataRequestStatusFile.new(filename) }
  let(:importer) { described_class.new(mobile_network: mno, datasource:) }

  before do
    create_extra_mobile_data_request_update_csv_file(filename, attrs)
  end

  after do
    remove_file(filename)
  end

  context 'when a vaild status change is in the csv file' do
    let(:attrs) do
      [{
        id: request.id,
        account_holder_name: request.account_holder_name,
        device_phone_number: request.device_phone_number,
        mobile_network_id: request.mobile_network_id,
        status: 'complete',
      }]
    end

    it 'updates the status of the matching requests' do
      importer.import!

      expect(request.reload.status).to eq('complete')
    end

    it 'records a ReportableEvent with the right attributes for each completion' do
      expect { importer.import! }.to change(ReportableEvent.where(record_type: 'ExtraMobileDataRequest', event_name: 'completion'), :count).from(0).to(1)
    end

    it 'returns a summary of the import' do
      summary = importer.import!
      expect(summary.has_updated_requests?).to be true
      expect(summary.has_unchanged_requests?).to be false
      expect(summary.has_errors?).to be false
      expect(summary.updated.first).to eq request
    end
  end

  context 'when no status changes are in the csv file' do
    let(:attrs) do
      [{
        id: request.id,
        account_holder_name: request.account_holder_name,
        device_phone_number: request.device_phone_number,
        mobile_network_id: request.mobile_network_id,
        status: request.status,
      }]
    end

    it 'does not update the status of the matching requests' do
      importer.import!

      expect(request.reload.status).to eq 'new'
    end

    it 'returns a summary of the import' do
      summary = importer.import!
      expect(summary.has_updated_requests?).to be false
      expect(summary.has_unchanged_requests?).to be true
      expect(summary.has_errors?).to be false
      expect(summary.unchanged.first).to eq request
    end
  end

  context 'when the status changes contain invalid status' do
    let(:requests) { create_list(:extra_mobile_data_request, 2, mobile_network: mno) }
    let(:attrs) do
      [{
        id: requests[0].id,
        account_holder_name: requests[0].account_holder_name,
        device_phone_number: requests[0].device_phone_number,
        mobile_network_id: requests[0].mobile_network_id,
        status: 'too_high',
      },
       {
         id: requests[1].id,
         account_holder_name: requests[1].account_holder_name,
         device_phone_number: requests[1].device_phone_number,
         mobile_network_id: requests[1].mobile_network_id,
         status: nil,
       }]
    end

    it 'does not update the status of the matching requests' do
      importer.import!

      expect(requests[0].reload.status).to eq 'new'
      expect(requests[1].reload.status).to eq 'new'
    end

    it 'returns a summary of the import' do
      summary = importer.import!
      expect(summary.has_updated_requests?).to be false
      expect(summary.has_unchanged_requests?).to be false
      expect(summary.has_errors?).to be true
      expect(summary.errors.first[:error]).to eq ["'too_high' is not a valid status"]
      expect(summary.errors.second[:error]).to eq ['No status provided']
    end
  end

  context 'when the attributes do not match the original request' do
    let(:requests) { create_list(:extra_mobile_data_request, 3, mobile_network: mno) }

    let(:attrs) do
      [{
        id: requests[0].id,
        account_holder_name: 'Geoffrey Falstaff',
        device_phone_number: requests[0].device_phone_number,
        mobile_network_id: requests[0].mobile_network_id,
        status: 'in_progress',
      },
       {
         id: requests[1].id,
         account_holder_name: requests[1].account_holder_name,
         device_phone_number: '07890123123',
         mobile_network_id: requests[1].mobile_network_id,
         status: 'in_progress',
       },
       {
         id: 9_302_909,
         account_holder_name: requests[2].account_holder_name,
         device_phone_number: requests[2].device_phone_number,
         mobile_network_id: requests[2].mobile_network_id,
         status: 'in_progress',
       }]
    end

    it 'updates the status of the requests with valid ids' do
      importer.import!

      expect(requests[0].reload.status).to eq 'in_progress'
      expect(requests[1].reload.status).to eq 'in_progress'
      expect(requests[2].reload.status).to eq 'new'
    end

    it 'returns a summary of the import' do
      summary = importer.import!
      expect(summary.has_updated_requests?).to be true
      expect(summary.has_unchanged_requests?).to be false
      expect(summary.has_errors?).to be true
      expect(summary.errors.first[:error]).to eq ['We could not find this request']
      expect(summary.updated).to match_array requests[0..1].map(&:reload)
    end
  end
end
