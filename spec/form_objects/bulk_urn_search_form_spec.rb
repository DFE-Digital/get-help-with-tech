require 'rails_helper'

RSpec.describe BulkUrnSearchForm do
  let(:school) { create(:school) }
  let(:closed_school) { create(:school, status: :closed) }

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

  describe '#schools' do
    subject(:form) do
      described_class.new(urns: "#{school.urn}\r\n#{closed_school.urn}\r\n")
    end

    it 'does not include closed schools' do
      expect(form.schools).to include(school)
      expect(form.schools).not_to include(closed_school)
    end
  end
end
