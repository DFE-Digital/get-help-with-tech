require 'rails_helper'

RSpec.describe SessionService do
  describe '::ttl_for_user' do
    context 'when support user' do
      let(:user) { build(:support_user) }

      it 'returns 7200' do
        expect(described_class.ttl_for_user(user)).to eql(7200.seconds)
      end
    end

    context 'when not a support user' do
      let(:user) { build(:school_user) }

      it 'returns 3600' do
        expect(described_class.ttl_for_user(user)).to eql(3600.seconds)
      end
    end
  end

  describe '::create_session!' do
    let(:user) { build(:support_user) }
    let(:session_id) { SecureRandom.hex }

    it 'sets expires_at' do
      described_class.create_session!(session_id: session_id, user: user)
      session = Session.find(session_id)
      expect(session.expires_at.utc).to be_within(10.seconds).of(Time.zone.now.utc + 2.hours)
    end
  end

  describe '::update_session!' do
    let!(:session) { Session.create(id: SecureRandom.hex, created_at: 30.minutes.ago, updated_at: 30.minutes.ago) }

    it 'updates expires_at' do
      ttl = 3.days
      described_class.update_session!(session.id, ttl)
      session.reload
      expect(session.expires_at.utc).to be_within(10.seconds).of(Time.zone.now.utc + ttl)
    end
  end
end
