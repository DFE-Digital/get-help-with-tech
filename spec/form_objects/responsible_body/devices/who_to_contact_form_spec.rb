require 'rails_helper'

RSpec.describe ResponsibleBody::Devices::WhoToContactForm do
  let(:school) { build(:school) }

  subject(:form) { described_class.new(school: school) }

  describe '#populate_details_from_second_contact' do
    context 'when there is no second contact' do
      let(:school) { build(:school) }

      it 'does not populate contact details' do
        form.populate_details_from_second_contact

        expect(form.full_name).to be_blank
        expect(form.email_address).to be_blank
        expect(form.phone_number).to be_blank
      end
    end

    context 'when there is a second contact' do
      let(:contact) { build(:school_contact, :contact, school: school) }
      let(:preorder_info) { create(:preorder_information, school_contact: contact) }
      let(:school) { create(:school) }

      before do
        school.preorder_information = preorder_info
      end

      it 'populates contact details' do
        form.populate_details_from_second_contact

        expect(form.full_name).to eql(contact.full_name)
        expect(form.email_address).to eql(contact.email_address)
        expect(form.phone_number).to eql(contact.phone_number)
      end
    end
  end

  describe '#preselect_who_to_contact' do
    context 'no current contact' do
      it 'leaves who_to_contact as nil' do
        form.preselect_who_to_contact
        expect(form.who_to_contact).to be_nil
      end
    end

    context 'when headteacher is current_contact' do
      let(:contact) { school.headteacher_contact }
      let(:preorder_info) { create(:preorder_information, school_contact: contact) }
      let(:school) { create(:school, :with_headteacher_contact) }

      before do
        school.preorder_information = preorder_info
      end

      it 'sets who_to_contact as headteacher' do
        form.preselect_who_to_contact
        expect(form.who_to_contact).to eql('headteacher')
      end
    end

    context 'when other contact is current_contact' do
      let(:contact) { create(:school_contact, :contact) }
      let(:preorder_info) { create(:preorder_information, school_contact: contact) }
      let(:school) { create(:school, :with_headteacher_contact) }

      before do
        school.preorder_information = preorder_info
      end

      it 'sets who_to_contact as someone_else' do
        form.preselect_who_to_contact
        expect(form.who_to_contact).to eql('someone_else')
      end
    end
  end
end
