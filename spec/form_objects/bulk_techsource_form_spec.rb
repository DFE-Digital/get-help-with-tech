require 'rails_helper'

RSpec.describe BulkTechsourceForm do
  describe 'validations' do
    context 'when no emails' do
      subject(:form) { described_class.new(emails: '') }

      it 'is invalid' do
        expect(form).to be_invalid
      end
    end

    context 'not one email per line with comma' do
      subject(:form) { described_class.new(emails: 'a@example.com, b@example.com') }

      it 'is invalid' do
        expect(form).to be_invalid
      end
    end

    context 'not one email per line with space' do
      subject(:form) { described_class.new(emails: 'a@example.com b@example.com') }

      it 'is invalid' do
        expect(form).to be_invalid
      end
    end

    context 'one email per line' do
      subject(:form) { described_class.new(emails: "a@example.com\r\nb@example.com\r\n") }

      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end

  describe '#array_of_emails' do
    subject(:form) { described_class.new(emails: "   a@example.com  \r\n   \r\nb@example.com\r\n\r\n") }

    it 'returns an array of entered emails' do
      expect(form.array_of_emails).to eql(['a@example.com', 'b@example.com'])
    end
  end
end
