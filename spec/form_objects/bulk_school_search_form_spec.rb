require 'rails_helper'

RSpec.describe BulkSchoolSearchForm do
  let(:school) { create(:school) }
  let(:fe_school) { create(:fe_school) }
  let(:closed_school) { create(:school, status: :closed) }

  describe '#array_of_identifiers' do
    subject(:form) do
      described_class.new(identifiers: "   123  \r\ \r\n456\r\n")
    end

    it 'returns correct array of identifiers' do
      expect(form.array_of_identifiers).to eql(%w[123 456])
    end
  end

  describe '#missing_identifiers' do
    subject(:form) do
      described_class.new(identifiers: "   #{school.urn}  \r\ \r\n456\r\n#{fe_school.ukprn}\r\n")
    end

    it 'returns array of identifiers with no matches' do
      expect(form.missing_identifiers).to eql(%w[456])
    end
  end

  describe '#schools' do
    subject(:form) do
      described_class.new(identifiers: "#{school.urn}\r\n#{closed_school.urn}\r\n#{fe_school.ukprn}\r\n")
    end

    it 'finds correct schools' do
      expect(form.schools).to include(school)
      expect(form.schools).not_to include(closed_school)
      expect(form.schools).to include(fe_school)
    end
  end
end
