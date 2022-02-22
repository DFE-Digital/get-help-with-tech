require 'rails_helper'

RSpec.describe Support::AllocationBatchJobsController do
  let(:support_user) { create(:support_user) }

  before do
    sign_in_as support_user
  end

  describe '#index' do
    it 'responds successfully' do
      get :index
      expect(response).to be_successful
    end
  end

  describe '#show' do
    let(:batch_id) { SecureRandom.uuid }
    let!(:jobs) do
      [
        create(:allocation_batch_job,
               urn: 'AAAAAA',
               batch_id:,
               allocation_delta: 3,
               applied_allocation_delta: 3,
               processed: true),
        create(:allocation_batch_job,
               ukprn: 'BBBBBB',
               batch_id:,
               allocation_delta: -2,
               processed: false),
        create(:allocation_batch_job,
               urn: 'CCCCCC',
               batch_id:,
               allocation_delta: 5,
               processed: false),
      ]
    end

    before do
      get :show, params: { id: batch_id }
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'paginate results' do
      expect(assigns(:pagination)).to be_present
    end

    it 'compute delta applied' do
      expect(assigns(:aggregate_allocation_change)).to eq(3)
    end

    it 'compute number of processed jobs' do
      expect(assigns(:number_of_processed_jobs)).to eq(1)
    end

    it 'compute total number of jobs in the batch' do
      expect(assigns(:total_number_of_jobs)).to eq(3)
    end

    it 'fetch only jobs in the batch' do
      expect(assigns(:jobs).map(&:batch_id).uniq).to eq([batch_id])
    end

    it 'sort jobs placing first those whose deltas mismatch, then sort by urn then by ukprn' do
      expect(assigns(:jobs)).to eq([jobs[2], jobs[1], jobs[0]])
    end
  end

  describe '#send_notifications' do
    let(:school) { create(:school) }
    let(:batch) { create(:allocation_batch_job, urn: school.urn) }

    it 'enqueues notifications to be sent' do
      expect {
        post :send_notifications, params: { id: batch.batch_id }
      }.to have_enqueued_job(AllocationEmailJob)
    end

    it 'redirects to batch' do
      post :send_notifications, params: { id: batch.batch_id }
      expect(response).to redirect_to(support_allocation_batch_job_path(id: batch.batch_id))
    end

    it 'populates flash message' do
      post :send_notifications, params: { id: batch.batch_id }
      expect(flash[:success]).to be_present
    end
  end
end
