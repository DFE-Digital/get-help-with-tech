require 'rails_helper'

RSpec.describe School, type: :model do
  describe 'validating URN' do
    let(:school) { subject }

    context 'the URN is 6 digits' do
      before do
        school.urn = '123456'
      end

      it 'is valid' do
        school.valid?
        expect(school.errors).not_to have_key(:urn)
      end
    end

    context 'the URN has more than 6 digits' do
      before do
        school.urn = '123456012'
      end

      it 'is not valid' do
        school.valid?
        expect(school.errors).to have_key(:urn)
        expect(school.errors[:urn]).to include('The URN must be 6 digits')
      end
    end

    context 'the URN has less than 6 digits' do
      before do
        school.urn = '1234'
      end

      it 'is not valid' do
        school.valid?
        expect(school.errors).to have_key(:urn)
        expect(school.errors[:urn]).to include('The URN must be 6 digits')
      end
    end

    context 'the URN contains non-numeric characters' do
      before do
        school.urn = '1234-Q'
      end

      it 'is not valid' do
        school.valid?
        expect(school.errors).to have_key(:urn)
        expect(school.errors[:urn]).to include('The URN must be 6 digits')
      end
    end

    context 'a URN is blank' do
      before do
        school.urn = nil
      end

      it 'is not valid' do
        school.valid?
        expect(school.errors).to have_key(:urn)
        expect(school.errors[:urn]).to include('Enter the unique reference number')
      end
    end
  end

  describe 'validating name' do
    context 'when a name is supplied' do
      let(:school) { subject }

      before do
        school.name = 'Big School'
      end

      it 'is valid' do
        school.valid?
        expect(school.errors).not_to have_key(:name)
      end
    end

    context 'when a name is not supplied' do
      let(:school) { subject }

      before do
        school.name = nil
      end

      it 'is not valid' do
        school.valid?
        expect(school.errors).to have_key(:name)
        expect(school.errors[:name]).to include('Enter the name of the establishment')
      end
    end
  end
end
