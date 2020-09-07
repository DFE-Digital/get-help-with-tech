require 'rails_helper'

RSpec.describe ResponsibleBody, type: :model do
  subject(:local_authority) { create(:local_authority) }

  describe '#next_school_sorted_ascending_by_name' do
    it 'allows navigating down a list of alphabetically-sorted schools' do
      zebra = create(:school, name: 'Zebra', responsible_body: local_authority)
      aardvark = create(:school, name: 'Aardvark', responsible_body: local_authority)
      tiger = create(:school, name: 'Tiger', responsible_body: local_authority)

      expect(local_authority.next_school_sorted_ascending_by_name(aardvark)).to eq(tiger)
      expect(local_authority.next_school_sorted_ascending_by_name(tiger)).to eq(zebra)
    end
  end

  describe '.convert_computacenter_urn' do
    context 'given a string starting with LEA' do
      it 'returns the same string with LEA removed' do
        expect(ResponsibleBody.convert_computacenter_urn('LEA12345')).to eq('12345')
      end
    end

    context 'given a string starting with t' do
      it 'returns the same string with t removed, padded to 8 chars with leading zeroes' do
        expect(ResponsibleBody.convert_computacenter_urn('t12345')).to eq('00012345')
      end
    end

    context 'given a string starting with SC' do
      it 'returns the same string, untransformed' do
        expect(ResponsibleBody.convert_computacenter_urn('SC12345')).to eq('SC12345')
      end
    end
  end

  describe '.find_by_computacenter_urn!' do
    let!(:trust_with_reference) { create(:trust, companies_house_number: '01234567') }
    let!(:la_with_reference) { create(:local_authority, gias_id: '123') }

    context 'given a string starting with LEA' do
      it 'returns the local authority matched by GIAS id' do
        expect(ResponsibleBody.find_by_computacenter_urn!('LEA123')).to eq(la_with_reference)
      end
    end

    context 'given a string starting with t' do
      it 'returns the trust matched by companies_house_number' do
        expect(ResponsibleBody.find_by_computacenter_urn!('t01234567')).to eq(trust_with_reference)
      end
    end
  end

  describe '#computacenter_identifier' do
    context 'when local authority' do
      subject(:responsible_body) { build(:local_authority) }

      it 'generates correct identifier' do
        expect(responsible_body.computacenter_identifier).to eql("LEA#{responsible_body.gias_id}")
      end
    end

    context 'when trust' do
      subject(:responsible_body) { build(:trust, companies_house_number: '0001') }

      it 'generates correct identifier' do
        expect(responsible_body.computacenter_identifier).to eql('t1')
      end
    end
  end
end
