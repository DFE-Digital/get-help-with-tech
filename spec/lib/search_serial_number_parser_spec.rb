require 'rails_helper'
require 'search_serial_number_parser'

RSpec.describe SearchSerialNumberParser do
  describe '#serial_numbers' do
    context 'none' do
      context 'nil' do
        subject { described_class.new(nil) }

        it { is_expected.to have_attributes(serial_numbers: be_empty) }
      end

      context 'empty' do
        subject { described_class.new('') }

        it { is_expected.to have_attributes(serial_numbers: be_empty) }
      end

      context 'whitespace' do
        subject { described_class.new(' ') }

        it { is_expected.to have_attributes(serial_numbers: be_empty) }
      end
    end

    context 'one' do
      subject { described_class.new('1234') }

      it { is_expected.to have_attributes(serial_numbers: contain_exactly('1234')) }
    end

    context 'multiple' do
      context 'comma-separated' do
        subject { described_class.new('1,2') }

        it { is_expected.to have_attributes(serial_numbers: contain_exactly('1', '2')) }
      end

      context 'space-separated' do
        subject { described_class.new('1 2') }

        it { is_expected.to have_attributes(serial_numbers: contain_exactly('1', '2')) }
      end

      context 'comma- and space-separated' do
        subject { described_class.new('1, 2') }

        it { is_expected.to have_attributes(serial_numbers: contain_exactly('1', '2')) }
      end
    end
  end
end
