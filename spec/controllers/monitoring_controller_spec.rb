require 'rails_helper'

RSpec.describe MonitoringController, type: :controller do
  describe 'healthcheck.json' do
    let(:json) do
      JSON.parse(response.body)
    end

    it 'returns json' do
      get :healthcheck, format: :json
      expect(response.media_type).to eq('application/json')
    end

    context 'when everything is OK' do
      it 'has status ok' do
        get :healthcheck, format: :json
        expect(response.status).to eq(200)
      end
    end

    context 'when not everything is OK' do
      before do
        allow(HealthcheckService).to receive(:db_status).and_return('DOWN')
      end

      it 'has status internal_server_error' do
        get :healthcheck, format: :json
        expect(response.status).to eq(500)
      end
    end

    context 'when GIT_BRANCH is present in the ENV', with_env_vars: { 'GIT_BRANCH' => 'my-branch-name' } do
      it 'reports GIT_BRANCH in the info/git/branch key' do
        get :healthcheck, format: :json

        expect(json['info']['git']['branch']).to eq('my-branch-name')
      end
    end

    context 'when GIT_BRANCH is not present in the ENV', with_env_vars: { 'GIT_BRANCH' => nil } do
      it 'reports null in the info/git/branch key' do
        get :healthcheck, format: :json

        expect(json['info']['git']['branch']).to eq(nil)
      end
    end

    context 'when GIT_COMMIT_SHA is present in the ENV', with_env_vars: { 'GIT_COMMIT_SHA' => 'my-commit-sha' } do
      it 'reports GIT_COMMIT_SHA in the info/git/commit_sha key' do
        get :healthcheck, format: :json

        expect(json['info']['git']['commit_sha']).to eq('my-commit-sha')
      end
    end

    context 'when GIT_COMMIT_SHA is not present in the ENV', with_env_vars: { 'GIT_COMMIT_SHA' => nil } do
      it 'reports null in the info/git/commit_sha key' do
        get :healthcheck, format: :json

        expect(json['info']['git']['commit_sha']).to eq(nil)
      end
    end

    context 'when DOCKER_IMAGE_ID is present in the ENV', with_env_vars: { 'DOCKER_IMAGE_ID' => 'abc123' } do
      it 'reports DOCKER_IMAGE_ID in the info/docker/image_id key' do
        get :healthcheck, format: :json

        expect(json['info']['docker']['image_id']).to eq('abc123')
      end
    end

    context 'when DOCKER_IMAGE_ID is not present in the ENV', with_env_vars: { 'DOCKER_IMAGE_ID' => nil } do
      it 'reports null in the info/docker/image_id key' do
        get :healthcheck, format: :json

        expect(json['info']['docker']['image_id']).to eq(nil)
      end
    end
  end
end
