require 'rails_helper'

RSpec.describe Computacenter::TechSource do
  describe '#available?' do
    context 'no maintenance windows' do
      subject(:techsource) { described_class.new(maintenance_windows: []) }

      specify { expect(techsource).to be_available }
    end

    context 'one maintenance window' do
      subject(:techsource) { described_class.new(maintenance_windows: [(Time.zone.parse('1 Jan 2021 9:00am')..Time.zone.parse('1 Jan 2021 10:00am'))]) }

      context 'before window' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 8:59am')) }

        specify { expect(techsource).to be_available }
      end

      context 'just at start of window' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:01am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just before end of window' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:59am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just after window' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 10:01am')) }

        specify { expect(techsource).to be_available }
      end
    end

    context 'two maintenance windows' do
      subject(:techsource) { described_class.new(maintenance_windows: [(Time.zone.parse('1 Jan 2021 9:00am')..Time.zone.parse('1 Jan 2021 10:00am')), (Time.zone.parse('1 Feb 2021 9:00am')..Time.zone.parse('1 Feb 2021 10:00am'))]) }

      context 'before first window' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 8:59am')) }

        specify { expect(techsource).to be_available }
      end

      context 'just at start of first window' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:01am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just before end of first window' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:59am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just after first window' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 10:01am')) }

        specify { expect(techsource).to be_available }
      end

      context 'just before second window' do
        before { Timecop.travel(Time.zone.parse('1 Feb 2021 8:59am')) }

        specify { expect(techsource).to be_available }
      end

      context 'just at start of second window' do
        before { Timecop.travel(Time.zone.parse('1 Feb 2021 9:01am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just before end of second window' do
        before { Timecop.travel(Time.zone.parse('1 Feb 2021 9:59am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just after second window' do
        before { Timecop.travel(Time.zone.parse('1 Feb 2021 10:01am')) }

        specify { expect(techsource).to be_available }
      end
    end
  end

  describe '#current_maintenance_window' do
    let(:first_window) { Time.zone.parse('1 Jan 2021 9:00am')..Time.zone.parse('1 Jan 2021 10:00am') }
    let(:second_window) { Time.zone.parse('1 Feb 2021 9:00am')..Time.zone.parse('1 Feb 2021 10:00am') }

    subject(:techsource) { described_class.new(maintenance_windows: [first_window, second_window]) }

    context 'before first' do
      before { Timecop.travel(Time.zone.parse('1 Jan 2021 8:59am')) }

      specify { expect(techsource.current_maintenance_window).to be_nil }
    end

    context 'during first' do
      before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:01am')) }

      specify { expect(techsource.current_maintenance_window).to eq(first_window) }
    end

    context 'between first and second' do
      before { Timecop.travel(Time.zone.parse('1 Jan 2021 10:01am')) }

      specify { expect(techsource.current_maintenance_window).to be_nil }
    end

    context 'during second' do
      before { Timecop.travel(Time.zone.parse('1 Feb 2021 9:01am')) }

      specify { expect(techsource.current_maintenance_window).to eq(second_window) }
    end

    context 'after second' do
      before { Timecop.travel(Time.zone.parse('1 Feb 2021 10:01am')) }

      specify { expect(techsource.current_maintenance_window).to be_nil }
    end
  end
end
