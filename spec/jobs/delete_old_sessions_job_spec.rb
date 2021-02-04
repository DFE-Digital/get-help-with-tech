require 'rails_helper'

RSpec.describe DeleteOldSessionsJob do
  subject(:job) { described_class.new }

  describe '#perform' do
    let!(:session1) { Session.create!(id: SecureRandom.uuid, expires_at: 4.hours.ago) }
    let!(:session2) { Session.create!(id: SecureRandom.uuid, expires_at: 1.hour.ago) }
    let!(:session3) { Session.create!(id: SecureRandom.uuid, expires_at: 30.minutes.from_now) }
    let!(:session4) { Session.create!(id: SecureRandom.uuid, expires_at: 1.hour.from_now) }

    let(:result) { job.perform }

    it 'deletes sessions expired by 2 hours' do
      expect { result }.to change(Session, :count).by(-1)

      expect(Session.find_by(id: session1.id)).to be_nil
      expect(Session.find_by(id: session2.id)).to be_present
      expect(Session.find_by(id: session3.id)).to be_present
      expect(Session.find_by(id: session4.id)).to be_present
    end
  end
end
