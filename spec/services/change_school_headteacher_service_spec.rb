require 'rails_helper'

RSpec.describe ChangeSchoolHeadteacherService, type: :model do
  let(:service) { described_class.new(school, **details) }
  let(:email_address) { Faker::Internet.email }
  let(:full_name) { Faker::Name.name }
  let(:details) do
    {
      email_address: email_address,
      full_name: full_name,
      id: headteacher_id,
    }
  end

  describe '#call' do
    context 'when the school have already a headteacher contact set' do
      let(:school) { create(:school, :with_headteacher) }
      let(:headteacher_id) { school.headteacher_id }

      let!(:result) { service.call }

      it 'update their details' do
        headteacher = school.reload.headteacher
        expect(headteacher.email_address).to eq(details[:email_address])
        expect(headteacher.full_name).to eq(details[:full_name])
        expect(headteacher.id).to eq(headteacher_id)
      end

      it 'return the headteacher contact with no errors' do
        expect(result).to be_a(SchoolContact)
        expect(result.errors).to be_empty
      end
    end

    context 'when the school have a non-headteacher contact' do
      let(:school) { create(:school) }
      let(:headteacher_id) { create(:school_contact, :contact, school:).id }

      let!(:result) { service.call }

      it 'set it as headteacher' do
        headteacher = school.reload.headteacher
        expect(headteacher.email_address).to eq(details[:email_address])
        expect(headteacher.full_name).to eq(details[:full_name])
        expect(headteacher.id).to eq(headteacher_id)
      end

      it 'return true' do
        expect(result).to be_a(SchoolContact)
        expect(result.errors).to be_empty
      end
    end

    context 'when the school have no contacts' do
      let(:school) { create(:school) }
      let(:headteacher_id) { school.contacts.first&.id }

      let!(:result) { service.call }

      it 'create a new headteacher contact' do
        headteacher = school.reload.headteacher
        expect(headteacher.email_address).to eq(details[:email_address])
        expect(headteacher.full_name).to eq(details[:full_name])
        expect(headteacher.id).not_to eq(headteacher_id)
      end

      it 'return true' do
        expect(result).to be_a(SchoolContact)
        expect(result.errors).to be_empty
      end
    end

    context 'when the new headteacher details are not valid' do
      let(:school) { create(:school) }
      let(:email_address) {}
      let(:headteacher_id) {}

      it 'do not change the school headteacher details' do
        expect {
          service.call
        }.not_to(change { school.reload.headteacher })
      end

      it 'return false' do
        result = service.call
        expect(result).to be_a(SchoolContact)
        expect(result.errors).to be_present
      end
    end
  end
end
