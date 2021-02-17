require 'rails_helper'

RSpec.describe MobileNetwork do
  describe '#pathsafe_brand' do
    subject(:mno) { build(:mobile_network) }

    it 'is all lower case' do
      expect(mno.pathsafe_brand).to eql(mno.pathsafe_brand.downcase)
    end

    context 'when the brand contains non alphanumeric characters' do
      before { mno.brand = 'SUPER #AWESOME network' }

      it 'replaces all of them with single underscores, and strips them from the start and end' do
        expect(mno.pathsafe_brand).to eql('super_awesome_network')
      end
    end

    context 'when the brand contains and ends with non alphanumeric characters' do
      before { mno.brand = 'SUPER #AWESOME network!!!' }

      it 'replaces all of them with single underscores, and strips them from the start and end' do
        expect(mno.pathsafe_brand).to eql('super_awesome_network')
      end
    end

    context 'when the brand contains and starts with non alphanumeric characters' do
      before { mno.brand = '@SUPER #AWESOME network' }

      it 'replaces all of them with single underscores, and strips them from the start and end' do
        expect(mno.pathsafe_brand).to eql('super_awesome_network')
      end
    end

    context 'when the brand has non alphanumeric characters at the start, end, and middle' do
      before { mno.brand = '!!The SUPER #AWESOME 非常快 20-20 network!!!' }

      it 'replaces all of them with single underscores, and strips them from the start and end' do
        expect(mno.pathsafe_brand).to eql('the_super_awesome_20_20_network')
      end
    end
  end
end
