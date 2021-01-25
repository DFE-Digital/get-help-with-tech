require 'rails_helper'

RSpec.describe FurtherEducationSchool do
  describe '#urn' do
    subject(:model) { described_class.new(ukprn: 123) }

    it 'falls back to show ukprn' do
      expect(model.urn).to be(123)
    end
  end

  describe '#institution_type' do
    context 'fe_type is sixth_form_college' do
      subject(:model) { described_class.new(fe_type: 'sixth_form_college') }

      it 'returns college' do
        expect(model.institution_type).to eql('college')
      end
    end

    context 'fe_type is agricultural_and_horticultural_college' do
      subject(:model) { described_class.new(fe_type: 'agricultural_and_horticultural_college') }

      it 'returns college' do
        expect(model.institution_type).to eql('college')
      end
    end

    context 'fe_type is special_post_16_institution' do
      subject(:model) { described_class.new(fe_type: 'special_post_16_institution') }

      it 'returns institution' do
        expect(model.institution_type).to eql('institution')
      end
    end

    context 'fe_type is something else' do
      subject(:model) { described_class.new(fe_type: '???') }

      it 'returns organisation' do
        expect(model.institution_type).to eql('organisation')
      end
    end
  end

  describe '#type_label' do
    context 'fe_type is sixth_form_college' do
      subject(:model) { described_class.new(fe_type: 'sixth_form_college') }

      it 'returns Sixth Form College' do
        expect(model.type_label).to eql('Sixth Form College')
      end
    end

    context 'fe_type is something else' do
      subject(:model) { described_class.new(fe_type: 'something_else') }

      it 'returns Other' do
        expect(model.type_label).to eql('Other')
      end
    end
  end
end
