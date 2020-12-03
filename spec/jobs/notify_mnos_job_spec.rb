require 'rails_helper'

RSpec.describe NotifyMnosJob do
  let(:mno_1_user) { create(:user) }
  let(:mno_2_user) { create(:user) }

  let(:mno1) { create(:mobile_network, users: [mno_1_user]) }
  let(:mno2) { create(:mobile_network, users: [mno_2_user]) }

  describe '#perform' do
    before do
      create(:extra_mobile_data_request, mobile_network: mno1)
      create(:extra_mobile_data_request, mobile_network: mno1)
      create(:extra_mobile_data_request, mobile_network: mno1, status: :in_progress)
      create(:extra_mobile_data_request, mobile_network: mno2, status: :in_progress)
    end

    it 'emails relevant mno users' do
      allow(MnoMailer).to receive(:notify_new_requests).and_call_original

      expect {
        described_class.perform_now
      }.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(MnoMailer).to have_received(:notify_new_requests).with(user: mno_1_user, number_of_new_requests: 2)
    end
  end
end
