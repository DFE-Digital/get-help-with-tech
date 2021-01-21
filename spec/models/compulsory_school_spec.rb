require 'rails_helper'

RSpec.describe CompulsorySchool do
  describe '#institution_type' do
    subject(:model) { described_class.new }

    it 'returns school' do
      expect(model.institution_type).to eql('school')
    end
  end
end
