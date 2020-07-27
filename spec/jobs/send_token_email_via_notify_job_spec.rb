require 'rails_helper'

RSpec.describe SendTokenEmailViaNotifyJob, type: :job do
  describe '#perform' do
    let(:user) { create(:local_authority_user) }
    let(:last_email) { ActionMailer::Base.deliveries.last }

    context 'given a valid user_id' do
      let(:job) { SendTokenEmailViaNotifyJob.new(user.id) }

      it 'sends the sign-in token email to the given user' do
        expect { job.perform_now }.to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(last_email.to[0]).to eq(user.email_address)
      end
    end

    context 'given an invalid user_id' do
      let(:job) { SendTokenEmailViaNotifyJob.new(-1) }

      it 'raises an ActiveRecord::RecordNotFound error' do
        expect { job.perform_now }.to raise_error(ActiveRecord::RecordNotFound)
        expect(last_email).to be_nil
      end
    end
  end
end
