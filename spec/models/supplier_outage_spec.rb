require 'rails_helper'

RSpec.describe SupplierOutage, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_at) }
    it { is_expected.to validate_presence_of(:end_at) }
  end

  describe 'time constraints' do
    context 'create' do
      before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:00am')) }

      context 'both start_at and end_at in the past' do
        subject { described_class.new(start_at: '30 Dec 2020 9:00am', end_at: '31 Dec 2020 9:00am') }

        it { is_expected.to be_invalid }
      end

      context 'start_at in the past and end_at in the future' do
        subject { described_class.new(start_at: '31 Dec 2020 9:00am', end_at: '2 Jan 2021 9:00am') }

        it { is_expected.to be_valid }
      end

      context 'both start_at and end_at in the future' do
        subject { described_class.new(start_at: '2 Jan 2021 9:00am', end_at: '3 Jan 2021 9:00am') }

        it { is_expected.to be_valid }
      end

      context 'start_at before end_at' do
        subject { described_class.new(start_at: '2 Jan 2021 9:00am', end_at: '4 Jan 2021 9:00am') }

        it { is_expected.to be_valid }
      end

      context 'start_at and end_at at same time' do
        subject { described_class.new(start_at: '2 Jan 2021 9:00am', end_at: '2 Jan 2021 9:00am') }

        it { is_expected.to be_invalid }
      end

      context 'end_at before start_at' do
        subject { described_class.new(start_at: '3 Jan 2021 9:00am', end_at: '2 Jan 2021 9:00am') }

        it { is_expected.to be_invalid }
      end
    end

    context 'update' do
      context 'future outage' do
        subject(:outage) { build(:supplier_outage, :in_the_future) }

        context 'moving into past' do
          specify { expect { outage.update!(start_at: 2.hours.ago, end_at: 1.hour.ago) }.to raise_error /can't be in the past/ }
        end
      end

      context 'current outage' do
        subject(:outage) { create(:supplier_outage, :current) }

        context 'end_at finished early' do
          specify { expect { outage.update!(end_at: 1.minute.ago) }.not_to raise_error }
        end
      end
    end
  end

  describe '.current' do
    subject(:current_outage) { SupplierOutage.current }

    before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:00am')) }

    let!(:outage) { create(:supplier_outage, start_at: Time.zone.parse('1 Jan 2021 10:00am'), end_at: Time.zone.parse('1 Jan 2021 11:00am')) }

    # overlapping?
    context 'before outage' do
      before { Timecop.travel(Time.zone.parse('1 Jan 2021 9:59am')) }

      specify { expect(current_outage).to be_none }
    end

    context 'during outage' do
      before { Timecop.travel(Time.zone.parse('1 Jan 2021 10:01am')) }

      specify { expect(current_outage).to include(outage) }
    end

    context 'after outage' do
      before { Timecop.travel(Time.zone.parse('1 Jan 2021 11:01am')) }

      specify { expect(current_outage).to be_none }
    end
  end
end
