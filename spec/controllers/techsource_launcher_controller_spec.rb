require 'rails_helper'

RSpec.describe TechsourceLauncherController, type: :controller do
  include ViewHelper

  let(:user) { create(:local_authority_user) }

  describe '#start' do
    context 'before techsource maintenance window' do
      before do
        Timecop.travel(Time.zone.local(2020, 9, 25, 23, 0, 0))
        sign_in_as user
      end

      it 'redirects to techsource' do
        get 'start'
        expect(response).to redirect_to(techsource_url)
      end
    end

    context 'during techsource maintenance window' do
      before do
        Timecop.travel(Time.zone.local(2020, 9, 26, 8, 0, 0))
        sign_in_as user
      end

      after do
        Timecop.return
      end

      it 'renders the unavailable page' do
        get 'start'
        expect(response).to render_template('unavailable')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'after techsource maintenance window' do
      before do
        Timecop.travel(Time.zone.local(2020, 9, 27, 3, 1, 0))
        sign_in_as user
      end

      after do
        Timecop.return
      end

      it 'redirects to techsource' do
        get 'start'
        expect(response).to redirect_to(techsource_url)
      end
    end
  end
end
