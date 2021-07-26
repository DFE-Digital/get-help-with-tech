require 'rails_helper'

RSpec.describe TechsourceLauncherController, type: :controller do
  let(:user) { create(:local_authority_user) }
  let(:techsource) { Computacenter::TechSource.new }

  before do
    Timecop.travel(Time.zone.parse('1 Jan 2021 8:00am'))
    create(:supplier_outage, start_at: Time.zone.parse('1 Jan 2021 9:00am'), end_at: Time.zone.parse('1 Jan 2021 10:00am'))
    sign_in_as user
  end

  describe '#start' do
    context 'before techsource maintenance window' do
      before do
        Timecop.travel(Time.zone.parse('1 Jan 2021 8:59am'))
        get 'start'
      end

      specify { expect(response).to redirect_to(techsource.url) }
    end

    context 'during techsource maintenance window' do
      before do
        Timecop.travel(Time.zone.parse('1 Jan 2021 9:01am'))
        get 'start'
      end

      specify { expect(response).to render_template('unavailable') }
      specify { expect(assigns(:available_at)).to eq('Friday 1 January 10:00am') }
    end

    context 'after techsource maintenance window' do
      before do
        Timecop.travel(Time.zone.parse('1 Jan 2021 10:01am'))
        get 'start'
      end

      specify { expect(response).to redirect_to(techsource.url) }
    end
  end
end
