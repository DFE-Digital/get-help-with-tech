require 'rails_helper'

RSpec.describe BulkUrnSearchForm do
  let(:school) { create(:school) }

  describe '#array_of_urns' do
    subject(:form) do
      described_class.new(urns: "   123  \r\ \r\n456\r\n")
    end

    it 'returns correct array of urns' do
      expect(form.array_of_urns).to eql(%w[123 456])
    end
  end

  describe '#missing_urns' do
    subject(:form) do
      described_class.new(urns: "   #{school.urn}  \r\ \r\n456\r\n")
    end

    it 'returns array of urns with no matches' do
      expect(form.missing_urns).to eql(%w[456])
    end
  end
end
