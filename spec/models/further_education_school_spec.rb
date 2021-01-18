require 'rails_helper'

RSpec.describe FurtherEducationSchool do
  describe '#urn' do
    subject(:model) { described_class.new(ukprn: 123) }

    it 'falls back to show ukprn' do
      expect(model.urn).to be(123)
    end
  end
end
