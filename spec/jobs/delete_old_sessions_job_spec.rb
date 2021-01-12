require 'rails_helper'

RSpec.describe DeleteOldSessionsJob do
  let(:job) { described_class.new }

  describe '#perform' do
    before do
      Timecop.travel(1.hour.ago)
      Session.create!(id: SecureRandom.uuid)
      Timecop.return

      Timecop.travel(5.hours.ago)
      Session.create!(id: SecureRandom.uuid)
      Timecop.return

      Timecop.travel(1.day.ago)
      Session.create!(id: SecureRandom.uuid)
      Timecop.return

      Timecop.travel(30.minutes.ago)
      2.times do
        Session.create!(id: SecureRandom.uuid)
      end
      Timecop.return
    end

    context 'given an :older_than param' do
      let(:result) { job.perform(older_than: 50.minutes.ago) }

      it 'deletes only the sessions older than the given param' do
        expect { result }.to change(Session, :count).by(-3)
      end
    end

    context 'given no :older_than param' do
      let(:result) { job.perform }

      it 'deletes only the sessions older than 4 times session_ttl_seconds Setting' do
        expect { result }.to change(Session, :count).by(-2)
      end
    end
  end
end
