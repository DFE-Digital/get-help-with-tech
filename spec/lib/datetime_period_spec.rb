require 'rails_helper'
require 'datetime_period'

RSpec.describe DatetimePeriod, type: :model do
  describe 'validations' do
    let(:monday_string) { '20 September 2021 09:00' }
    let(:tuesday_string) { '21 September 2021 09:00' }

    it { is_expected.to validate_presence_of(:start_at_string) }
    it { is_expected.to validate_presence_of(:end_at_string) }

    it { is_expected.not_to allow_values('blah').for(:start_at_string) }
    it { is_expected.not_to allow_values('blah').for(:end_at_string) }

    context 'start before end' do
      subject { described_class.new(start_at_string: monday_string, end_at_string: tuesday_string) }

      it { is_expected.to be_valid }
    end

    context 'end before start' do
      subject { described_class.new(start_at_string: tuesday_string, end_at_string: monday_string) }

      it { is_expected.to be_invalid }
    end

    context 'same end and start' do
      subject { described_class.new(start_at_string: monday_string, end_at_string: monday_string) }

      it { is_expected.to be_invalid }
    end
  end

  describe '#to_s' do
    let(:start_at_string) { '1 Jan 2021 09:00' }
    let(:end_at_string) { '2 Jan 2021 10:00' }
    let(:period) { described_class.new(start_at_string:, end_at_string:) }

    specify { expect(period.to_s).to eq('2021-01-01T09:00--2021-01-02T10:00') }
  end
end
