require 'rails_helper'
require 'search_serial_number_parser'

RSpec.describe SearchSerialNumberParser do
  describe '#serial_numbers' do
    context 'only single allowed' do
      context 'nil' do
        subject { described_class.new(serial_numbers_string: nil, multiple: false) }

        it { is_expected.to have_attributes(serial_numbers: be_empty) }
      end

      context 'empty' do
        subject { described_class.new(serial_numbers_string: '', multiple: false) }

        it { is_expected.to have_attributes(serial_numbers: be_empty) }
      end

      context 'blank' do
        subject { described_class.new(serial_numbers_string: ' ', multiple: false) }

        it { is_expected.to have_attributes(serial_numbers: be_empty) }
      end

      context 'leading and trailing whitespace' do
        subject { described_class.new(serial_numbers_string: ' 1234 ', multiple: false) }

        it { is_expected.to have_attributes(serial_numbers: contain_exactly('1234')) }
      end

      context 'attempting multiple search' do
        subject { described_class.new(serial_numbers_string: '1234, 5678', multiple: false) }

        it { is_expected.to have_attributes(serial_numbers: contain_exactly('1234, 5678')) }
      end
    end

    context 'multiple allowed' do
      context 'none' do
        context 'nil' do
          subject { described_class.new(serial_numbers_string: nil, multiple: true) }

          it { is_expected.to have_attributes(serial_numbers: be_empty) }
        end

        context 'empty' do
          subject { described_class.new(serial_numbers_string: '', multiple: true) }

          it { is_expected.to have_attributes(serial_numbers: be_empty) }
        end

        context 'whitespace' do
          subject { described_class.new(serial_numbers_string: ' ', multiple: true) }

          it { is_expected.to have_attributes(serial_numbers: be_empty) }
        end
      end

      context 'one' do
        subject { described_class.new(serial_numbers_string: '1234', multiple: true) }

        it { is_expected.to have_attributes(serial_numbers: contain_exactly('1234')) }
      end

      context 'one with leading and trailing whitespace' do
        subject { described_class.new(serial_numbers_string: ' 1234 ', multiple: true) }

        it { is_expected.to have_attributes(serial_numbers: contain_exactly('1234')) }
      end

      context 'multiple' do
        context 'comma-separated' do
          subject { described_class.new(serial_numbers_string: '1,2', multiple: true) }

          it { is_expected.to have_attributes(serial_numbers: contain_exactly('1', '2')) }
        end

        context 'space-separated' do
          subject { described_class.new(serial_numbers_string: '1 2', multiple: true) }

          it { is_expected.to have_attributes(serial_numbers: contain_exactly('1', '2')) }
        end

        context 'comma- and space-separated' do
          subject { described_class.new(serial_numbers_string: '1, 2', multiple: true) }

          it { is_expected.to have_attributes(serial_numbers: contain_exactly('1', '2')) }
        end
      end
    end
  end
end
