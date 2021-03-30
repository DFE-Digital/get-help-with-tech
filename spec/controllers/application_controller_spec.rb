require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    def index
      head :ok
    end
  end

  describe '#set_sentry_user' do
    let(:sentry) { instance_double('sentry').as_null_object }

    before do
      stub_const('Sentry', sentry)
    end

    context 'when user not signed in' do
      it 'sets sentry user to nil' do
        get :index
        expect(sentry).to have_received(:set_user).with(id: nil)
      end
    end

    context 'when user signed in' do
      let(:user) { create(:school_user) }

      before do
        sign_in_as user
      end

      it 'sets sentry user to user id' do
        get :index
        expect(sentry).to have_received(:set_user).with(id: user.id)
      end
    end
  end
end
