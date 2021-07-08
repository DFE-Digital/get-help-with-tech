require 'rails_helper'

RSpec.describe TechsourceLauncherController, type: :controller do
  let(:user) { create(:local_authority_user) }
  let(:maintenance_windows) { [(Time.zone.parse('1 Jan 2021 9:00am')..Time.zone.parse('1 Jan 2021 10:00am'))] }
  let(:techsource) { Computacenter::TechSource.new(maintenance_windows: maintenance_windows) }

  before do
    allow_any_instance_of(Computacenter::TechSource).to receive(:maintenance_windows).and_return(techsource.maintenance_windows) # rubocop:disable RSpec/AnyInstance
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
