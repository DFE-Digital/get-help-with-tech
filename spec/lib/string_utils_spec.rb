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
end
