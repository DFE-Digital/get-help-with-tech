require 'rails_helper'

RSpec.describe DeleteExpiredDownloadsJob do
  subject(:job) { described_class.new }

  describe '#perform' do
    let!(:download1) { Download.create!(created_at: 8.days.ago) }
    let!(:download2) { Download.create!(created_at: 9.days.ago) }
    let!(:download3) { Download.create!(created_at: 6.days.ago) }
    let!(:download4) { Download.create!(created_at: 1.hour.ago) }

    let(:result) { job.perform }

    it 'deletes downloads expired by 7 days' do
      expect { result }.to change(Download, :count).by(-2)

      expect(Download.find_by(id: download1.id)).to be_nil
      expect(Download.find_by(id: download2.id)).to be_nil
      expect(Download.find_by(id: download3.id)).to be_present
      expect(Download.find_by(id: download4.id)).to be_present
    end
  end
end
