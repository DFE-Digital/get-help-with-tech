require 'rails_helper'

RSpec.describe Support::School::ChangeHeadteacherForm, type: :model do
  describe '#headteacher?' do
    let(:school) { build_stubbed(:school) }

    subject(:form) { described_class.new(school:, role:) }

    context 'when the role of the form contact is :headteacher' do
      let(:role) { 'headteacher' }

      it 'return true' do
        expect(form.headteacher?).to be_truthy
      end
    end

    context 'when the role of the form contact is other than :headteacher' do
      let(:role) {}

      it 'return false' do
        expect(form.headteacher?).to be_falsey
      end
    end
  end

  describe '#save' do
    let(:school) { create(:school, :with_headteacher) }
    let(:headteacher_id) { school.headteacher_id }

    context 'when the new headteacher details cannot be set' do
      let(:new_email_address) { 'invalid_email_address' }

      subject(:form) { described_class.new(school:, id: headteacher_id, email_address: new_email_address) }

      it 'return false' do
        expect(form.save).to be_falsey
      end

      it 'do not change the school headteacher' do
        expect { form.save }.not_to change(school.reload, :headteacher)
      end

      it 'add errors to the form object' do
        expect(form.save).to be_falsey
        expect(form.errors[:email_address]).not_to be_empty
      end
    end

    context 'when the new headteacher details can be set' do
      let(:new_email_address) { Faker::Internet.email }

      subject(:form) { described_class.new(school:, id: headteacher_id, email_address: new_email_address) }

      it 'return true' do
        expect(form.save).to be_truthy
      end

      it 'change the school headteacher details' do
        expect(form.save).to be_truthy
        expect(school.reload.headteacher_email_address).to eq(new_email_address)
      end

      it 'do not add errors to the form object' do
        expect(form.save).to be_truthy
        expect(form.errors).to be_empty
      end
    end
  end
end
