require 'rails_helper'

RSpec.describe Computacenter::TechSource do
  subject(:techsource) { described_class.new }

  describe '#available?' do
    context 'no supplier outages' do
      specify { expect(techsource).to be_available }
    end

    context 'one supplier outage' do
      before do
        Timecop.travel(Time.zone.parse('1 Jan 2021 8:59am'))
        create(:supplier_outage, start_at: Time.zone.parse('1 Jan 2021 9:00am'), end_at: Time.zone.parse('1 Jan 2021 10:00am'))
      end

      context 'before outage' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 8:59am')) }

        specify { expect(techsource).to be_available }
      end

      context 'just at start of outage' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:01am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just before end of outage' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:59am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just after outage' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 10:01am')) }

        specify { expect(techsource).to be_available }
      end
    end

    context 'two supplier outages' do
      before do
        Timecop.travel(Time.zone.parse('1 Jan 2021 8:59am'))
        create(:supplier_outage, start_at: Time.zone.parse('1 Jan 2021 9:00am'), end_at: Time.zone.parse('1 Jan 2021 10:00am'))
        create(:supplier_outage, start_at: Time.zone.parse('1 Feb 2021 9:00am'), end_at: Time.zone.parse('1 Feb 2021 10:00am'))
      end

      context 'before first outage' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 8:59am')) }

        specify { expect(techsource).to be_available }
      end

      context 'just at start of first outage' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:01am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just before end of first outage' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:59am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just after first outage' do
        before { Timecop.travel(Time.zone.parse('1 Jan 2021 10:01am')) }

        specify { expect(techsource).to be_available }
      end

      context 'just before second outage' do
        before { Timecop.travel(Time.zone.parse('1 Feb 2021 8:59am')) }

        specify { expect(techsource).to be_available }
      end

      context 'just at start of second outage' do
        before { Timecop.travel(Time.zone.parse('1 Feb 2021 9:01am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just before end of second outage' do
        before { Timecop.travel(Time.zone.parse('1 Feb 2021 9:59am')) }

        specify { expect(techsource).not_to be_available }
      end

      context 'just after second outage' do
        before { Timecop.travel(Time.zone.parse('1 Feb 2021 10:01am')) }

        specify { expect(techsource).to be_available }
      end
    end
  end

  describe '#current_supplier_outage' do
    before { Timecop.travel(Time.zone.parse('1 Jan 2021 8:59am')) }

    let!(:first_outage) { create(:supplier_outage, start_at: Time.zone.parse('1 Jan 2021 9:00am'), end_at: Time.zone.parse('1 Jan 2021 10:00am')) }
    let!(:second_outage) { create(:supplier_outage, start_at: Time.zone.parse('1 Feb 2021 9:00am'), end_at: Time.zone.parse('1 Feb 2021 10:00am')) }

    context 'before first' do
      before { Timecop.travel(Time.zone.parse('1 Jan 2021 8:59am')) }

      specify { expect(techsource.current_supplier_outage).to be_nil }
    end

    context 'during first' do
      before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:01am')) }

      specify { expect(techsource.current_supplier_outage).to eq(first_outage) }
    end

    context 'between first and second' do
      before { Timecop.travel(Time.zone.parse('1 Jan 2021 10:01am')) }

      specify { expect(techsource.current_supplier_outage).to be_nil }
    end

    context 'during second' do
      before { Timecop.travel(Time.zone.parse('1 Feb 2021 9:01am')) }

      specify { expect(techsource.current_supplier_outage).to eq(second_outage) }
    end

    context 'after second' do
      before { Timecop.travel(Time.zone.parse('1 Feb 2021 10:01am')) }

      specify { expect(techsource.current_supplier_outage).to be_nil }
    end
  end
end
