require 'rails_helper'

RSpec.describe Support::School::ChangeResponsibleBodyForm, type: :model do
  it { is_expected.to validate_presence_of(:school) }
  it { is_expected.to validate_presence_of(:responsible_body) }

  describe '#responsible_body_id' do
    let(:school) { build_stubbed(:school) }
    let(:responsible_body_id) { school.responsible_body_id.next }

    context 'when a new responsible_body_id is given at initialization time' do
      subject(:form) { described_class.new(school: school, responsible_body_id: responsible_body_id) }

      it 'return the new responsible_body_id' do
        expect(form.responsible_body_id).to eq(responsible_body_id)
      end
    end

    context 'when a new responsible_body_id is not given at initialization time' do
      subject(:form) { described_class.new(school: school) }

      it 'return the given school responsible_body_id' do
        expect(form.responsible_body_id).to eq(school.responsible_body_id)
      end
    end
  end

  describe '#responsible_body' do
    let(:school) { create(:school) }

    context 'when a new responsible_body_id is given at initialization time' do
      let(:new_responsible_body) { create(:trust) }

      subject(:form) { described_class.new(school: school, responsible_body_id: new_responsible_body.id) }

      it 'return the new responsible_body' do
        expect(form.responsible_body).to eq(new_responsible_body)
      end
    end

    context 'when a new responsible_body_id is not given at initialization time' do
      subject(:form) { described_class.new(school: school) }

      it 'return the given school responsible_body' do
        expect(form.responsible_body).to eq(school.responsible_body)
      end
    end
  end

  describe '#responsible_body_options' do
    subject(:form) { described_class.new }

    let!(:open_rbs) { create_list(:trust, 2) }

    before do
      create_list(:trust, 2, status: :closed)
    end

    it 'return a list of objects from the existing open responsible bodies including their id and name' do
      expect(form.responsible_body_options.map(&:id)).to match_array(open_rbs.map(&:id))
      expect(form.responsible_body_options.map(&:name)).to match_array(open_rbs.map(&:name))
    end
  end

  describe '#save' do
    context 'when the form is not valid' do
      let(:school) { create(:school) }
      let(:responsible_body_id) { school.responsible_body_id }

      subject(:form) { described_class.new(school: school, responsible_body_id: responsible_body_id.next) }

      it 'return false' do
        expect(form.save).to be_falsey
      end

      it 'do not change the school responsible body' do
        expect(school.reload.responsible_body_id).to eq(responsible_body_id)
      end
    end

    context 'when the form is valid' do
      let(:school) { create(:school, :with_preorder_information) }
      let(:new_responsible_body) { create(:trust) }

      subject(:form) { described_class.new(school: school, responsible_body_id: new_responsible_body.id) }

      it 'return true' do
        expect(form.save).to be_truthy
      end

      it 'change the school responsible body' do
        change_rb = instance_spy(ChangeSchoolResponsibleBodyService, call: true)
        allow(ChangeSchoolResponsibleBodyService).to receive(:new).with(school, new_responsible_body) { change_rb }

        expect(form.save).to be_truthy
        expect(change_rb).to have_received(:call)
      end
    end
  end
end
