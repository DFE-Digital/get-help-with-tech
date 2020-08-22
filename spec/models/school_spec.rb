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

  describe '#preorder_status_or_default' do
    subject(:school) { build(:school) }

    context 'when the school has a preorder_information record with a status' do
      before do
        school.preorder_information = PreorderInformation.new(school: school, status: 'ready')
      end

      it 'returns the status from the preorder_information record' do
        expect(school.preorder_status_or_default).to eq('ready')
      end
    end

    context 'when the school has a preorder_information record without a status' do
      before do
        PreorderInformation.new(school: school, status: nil)
      end

      it 'infers the status' do
        allow(school.preorder_information).to receive(:infer_status).and_return('inferred_status')
        expect(school.preorder_status_or_default).to eq('inferred_status')
      end
    end

    context 'when the school has no preorder status and the responsible_body is set to manage orders centrally' do
      before do
        school.preorder_information = nil
        school.responsible_body = build(:trust, who_will_order_devices: 'responsible_body')
      end

      it 'returns "needs_info"' do
        expect(school.preorder_status_or_default).to eq('needs_info')
      end
    end

    context 'when the school has no preorder status and the responsible_body is set to schools managing orders' do
      before do
        school.preorder_information = nil
        school.responsible_body = build(:trust, who_will_order_devices: 'school')
      end

      it 'returns "needs_contact"' do
        expect(school.preorder_status_or_default).to eq('needs_contact')
      end
    end
  end

  describe '#type_label' do
    subject { school.type_label }

    context 'for a special school' do
      let(:school) { build(:school, establishment_type: :special) }

      it { is_expected.to eq('Special school') }
    end

    context 'when the school is not a special school and the phase is primary' do
      let(:school) { build(:school, establishment_type: :academy, phase: :primary) }

      it { is_expected.to eq('Primary school') }
    end

    context 'when the school is not a special school and the phase is sixteen_plus' do
      let(:school) { build(:school, establishment_type: :local_authority, phase: :sixteen_plus) }

      it { is_expected.to eq('Sixteen plus school') }
    end

    context 'when the school is not a special school and the phase is not set' do
      let(:school) { build(:school, establishment_type: :academy, phase: :phase_not_applicable) }

      it { is_expected.to be_blank }
    end
  end
end
