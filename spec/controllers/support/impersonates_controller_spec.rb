require 'rails_helper'

RSpec.describe Support::ImpersonatesController do
  let(:support_user) { create(:support_user, role: 'third_line') }
  let(:other_support_user) { create(:support_user) }
  let(:computacenter_user) { create(:computacenter_user) }
  let(:impersonated_user) { create(:school_user) }

  before do
    sign_in_as support_user
  end

  describe '#create' do
    it 'sets session[:impersonated_user_id] of impersonated user' do
      post :create, params: { impersonated_user_id: impersonated_user.id }
      expect(session[:impersonated_user_id]).to eql(impersonated_user.id.to_s)
    end

    it 'redirects to impersonated user start page' do
      post :create, params: { impersonated_user_id: impersonated_user.id }
      expect(response).to redirect_to("/schools/#{impersonated_user.school.urn}")
    end

    it 'cannot impersonate yourself' do
      post :create, params: { impersonated_user_id: support_user.id }
      expect(session[:impersonated_user_id]).not_to eql(support_user.id.to_s)
    end

    it 'cannot impersonate another support user' do
      post :create, params: { impersonated_user_id: other_support_user.id }
      expect(session[:impersonated_user_id]).not_to eql(other_support_user.id.to_s)
    end

    it 'cannot impersonate a computacenter user' do
      post :create, params: { impersonated_user_id: computacenter_user.id }
      expect(session[:impersonated_user_id]).not_to eql(computacenter_user.id.to_s)
    end
  end

  describe '#destroy' do
    it 'clears session[:impersonated_user_id]' do
      session[:impersonated_user_id] = impersonated_user.id
      delete :destroy
      expect(session[:impersonated_user_id]).to be_blank
    end

    it 'redirects to support user start page' do
      delete :destroy
      expect(response).to redirect_to('/support')
    end
  end
end
