require 'rails_helper'

RSpec.describe AllocationEmailJob do
  let(:allocation_batch_job) { create(:allocation_batch_job, urn: school.urn) }
  let(:school) { create(:school) }

  describe '#perform' do
    let(:mock_service) { instance_double('SchoolCanOrderDevicesNotifications', call: true) }

    it 'calls service to send notifications' do
      allow(SchoolCanOrderDevicesNotifications).to receive(:new).and_return(mock_service)

      described_class.perform_now(allocation_batch_job)

      expect(SchoolCanOrderDevicesNotifications).to have_received(:new).with(school)
      expect(mock_service).to have_received(:call)
    end

    it 'updates sent_notification flag' do
      expect {
        described_class.perform_now(allocation_batch_job)
      }.to change { allocation_batch_job.reload.sent_notification }.from(false).to(true)
    end

    context 'if notication has already been sent' do
      let(:allocation_batch_job) { create(:allocation_batch_job, urn: school.urn, sent_notification: true) }

      it 'does not send notfication again' do
        allow(SchoolCanOrderDevicesNotifications).to receive(:new).and_return(mock_service)

        described_class.perform_now(allocation_batch_job)

        expect(SchoolCanOrderDevicesNotifications).not_to have_received(:new).with(school)
        expect(mock_service).not_to have_received(:call)
      end
    end
  end
end
