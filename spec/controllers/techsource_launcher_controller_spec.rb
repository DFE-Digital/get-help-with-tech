require 'rails_helper'

RSpec.describe TechsourceLauncherController, type: :controller do
  let(:user) { create(:local_authority_user) }
  let(:techsource) { Computacenter::TechSource.new }

  before do
    stub_const('Computacenter::TechSource::NEXT_MAINTENANCE', {
      window_start: Time.zone.local(2020, 11, 28, 7, 0, 0),
      window_end: Time.zone.local(2020, 11, 28, 23, 0, 0),
      maintenance_on_date: Date.new(2020, 11, 28),
      reopened_on_date: Date.new(2020, 11, 29),
    })
  end

  describe '#start' do
    context 'before techsource maintenance window' do
      before do
        Timecop.travel(Time.zone.local(2020, 11, 27, 23, 0, 0))
        sign_in_as user
      end

      it 'redirects to techsource' do
        get 'start'
        expect(response).to redirect_to(techsource.url)
      end
    end

    context 'during techsource maintenance window' do
      before do
        Timecop.travel(Time.zone.local(2020, 11, 28, 8, 0, 0))
        sign_in_as user
      end

      it 'renders the unavailable page' do
        stub_const('Computacenter::TechSource::MAINTENANCE_WINDOW', Time.zone.local(2020, 11, 28, 7, 0, 0)..Time.zone.local(2020, 11, 28, 14, 0, 0))
        get 'start'
        expect(response).to render_template('unavailable')
        expect(response).to have_http_status(:ok)
        expect(assigns(:available_at)).to eq('Saturday 28 November 02:00pm')
      end
    end

    context 'after techsource maintenance window' do
      before do
        Timecop.travel(Time.zone.local(2020, 11, 29, 3, 1, 0))
        sign_in_as user
      end

      it 'redirects to techsource' do
        get 'start'
        expect(response).to redirect_to(techsource.url)
      end
    end
  end
end
