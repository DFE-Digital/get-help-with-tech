require 'rails_helper'

RSpec.describe Computacenter::TechSourceMaintenanceBannerComponent, type: :component do
  let(:techsource) { Computacenter::TechSource.new(maintenance_windows: maintenance_windows) }

  subject(:banner) { described_class.new(techsource) }

  describe '#message' do
    context 'within window' do
      let(:maintenance_windows) { [Time.zone.parse('4 Jan 2021 09:00')..Time.zone.parse('4 Jan 2021 22:00')] }

      before { Timecop.travel(Time.zone.parse('4 Jan 2021 15:00')) }

      specify { expect(banner.message).to eq('The TechSource website will be closed for maintenance on <span class="app-no-wrap">Monday 4 January 09:00am.</span> You can order devices when it reopens on <span class="app-no-wrap">Monday 4 January 10:00pm.</span>') }
    end
  end

  describe '#render?' do
    let(:maintenance_windows) { [Time.zone.parse('4 Jan 2021 09:00')..Time.zone.parse('4 Jan 2021 10:00')] }

    context 'one minute before midnight two days before' do
      before do
        Timecop.travel(Time.zone.parse('1 Jan 2021 23:59'))
        render_inline(banner)
      end

      specify { expect(rendered_component).to be_blank }
    end

    context 'one minute after midnight two days before' do
      before do
        Timecop.travel(Time.zone.parse('2 Jan 2021 00:01'))
        render_inline(banner)
      end

      specify { expect(rendered_component).to be_present }
    end

    context 'one minute before end of maintenance window' do
      before do
        Timecop.travel(Time.zone.parse('4 Jan 2021 09:59'))
        render_inline(banner)
      end

      specify { expect(rendered_component).to be_present }
    end

    context 'one minute after maintenance window' do
      before do
        Timecop.travel(Time.zone.parse('4 Jan 2021 10:01'))
        render_inline(banner)
      end

      specify { expect(rendered_component).to be_blank }
    end

    context 'two maintenance windows' do
      let(:maintenance_windows) { [Time.zone.parse('4 Jan 2021 09:00')..Time.zone.parse('4 Jan 2021 10:00'), Time.zone.parse('1 Feb 2021 09:00')..Time.zone.parse('1 Feb 2021 10:00')] }

      context 'within first maintenance banner window' do
        before do
          Timecop.travel(Time.zone.parse('4 Jan 2021 9:59'))
          render_inline(banner)
        end

        specify { expect(rendered_component).to be_present }
      end

      context 'between maintenance banner windows' do
        before do
          Timecop.travel(Time.zone.parse('4 Jan 2021 10:01'))
          render_inline(banner)
        end

        specify { expect(rendered_component).to be_blank }
      end

      context 'within second maintenance banner window' do
        before do
          Timecop.travel(Time.zone.parse('1 Feb 2021 9:01'))
          render_inline(banner)
        end

        specify { expect(rendered_component).to be_present }
      end
    end
  end
end
