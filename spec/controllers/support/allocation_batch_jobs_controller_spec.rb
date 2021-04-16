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
    let(:school) { create(:school) }
    let(:batch) { create(:allocation_batch_job, urn: school.urn) }

    it 'responds successfully' do
      get :show, params: { id: batch.batch_id }
      expect(response).to be_successful
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
