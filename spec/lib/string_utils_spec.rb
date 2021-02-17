require 'rails_helper'
require 'string_utils'

describe StringUtils do
  let(:test_class) { Class.new { extend StringUtils } }

  describe '#split_string' do
    it 'splits an input string into two sections at the last word break before the specified limit' do
      result = test_class.split_string('banana pineapple strawberry', limit: 20)
      expect(result).to eq(['banana pineapple', 'strawberry'])
    end

    it 'truncates the second section to the limit when longer' do
      result = test_class.split_string('banana pineapple strawberry', limit: 15)
      expect(result).to eq(['banana', 'pineapple straw'])
    end

    it 'returns two sections when the input is less than the limit' do
      result = test_class.split_string('banana pineapple strawberry', limit: 30)
      expect(result).to eq(['banana pineapple strawberry', ''])
    end
  end

  describe '#redact' do
    context 'given a string' do
      it 'returns an ellipsis' do
        expect(test_class.redact('a long string')).to eq('…')
      end

      context 'and a redaction' do
        it 'returns the redaction' do
          expect(test_class.redact('a long string', redaction: '___XXX___')).to eq('___XXX___')
        end
      end

      context 'and a first: N param' do
        it 'returns the first N characters plus an ellipsis' do
          expect(test_class.redact('a long string', first: 3)).to eq('a l…')
        end

        context 'and a last: M param' do
          it 'returns the first N characters plus an ellipsis plus the last M characters' do
            expect(test_class.redact('a long string', first: 1, last: 2)).to eq('a…ng')
          end
        end
      end

      context 'and a last: N param' do
        it 'returns an ellipsis plus the last N characters' do
          expect(test_class.redact('a long string', last: 3)).to eq('…ing')
        end
      end

      context 'with first N and last M params and a redaction' do
        it 'returns the first N characters plus the redaction plus the last M characters' do
          expect(test_class.redact('a long string', first: 1, last: 2, redaction: '-REDACTED-')).to eq('a-REDACTED-ng')
        end
      end
    end
  end
end
