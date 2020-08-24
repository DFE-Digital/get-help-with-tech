require 'rails_helper'

describe SchoolDetailsSummaryListComponent do
  let(:school) { create(:school, :primary, :la_maintained) }
  let(:headteacher) do
    create(:school_contact, :headteacher,
           full_name: 'Davy Jones',
           email_address: 'davy.jones@school.sch.uk',
           phone_number: '12345')
  end

  subject(:result) { render_inline(described_class.new(school: school)) }

  context 'when the school will place device orders' do
    before do
      create(:preorder_information, school: school, who_will_order_devices: :school)
      create(:school_device_allocation, school: school, device_type: 'std_device', allocation: 3)
    end

    it 'confirms that fact' do
      expect(result.css('dd')[3].text).to include('The school orders devices')
    end

    it 'renders the school allocation' do
      expect(result.css('dd')[1].text).to include('3 devices')
    end

    it 'renders the school type' do
      expect(result.css('dd')[2].text).to include('Primary school')
    end

    it 'renders the school details' do
      expect(result.css('dd')[0].text).to include('Needs a contact')
    end

    context 'and the headteacher has been set as the school contact' do
      it 'displays the headteacher details' do
        create(:preorder_information,
               school: school,
               who_will_order_devices: :school,
               school_contact: headteacher)

        expect(result.css('dt')[4].text).to include('School contact')
        expect(result.css('dd')[4].text).to include('Headteacher: Davy Jones')
        expect(result.css('dd')[4].text).to include('davy.jones@school.sch.uk')
        expect(result.css('dd')[4].text).to include('12345')
      end
    end

    context 'and someone else has been set as the school contact' do
      it "displays the new contact's details" do
        new_contact = create(:school_contact, :contact,
                             full_name: 'Jane Smith',
                             email_address: 'abc@example.com',
                             phone_number: '12345')
        create(:preorder_information,
               school: school,
               who_will_order_devices: :school,
               school_contact: new_contact)

        expect(result.css('dt')[4].text).to include('School contact')
        expect(result.css('dd')[4].text).to include('Jane Smith')
        expect(result.css('dd')[4].text).to include('abc@example.com')
        expect(result.css('dd')[4].text).to include('12345')
      end
    end
  end

  context 'when the responsible body will place device orders' do
    let(:school) { create(:school, :primary, :academy) }

    it 'confirms that fact' do
      create(:preorder_information, school: school, who_will_order_devices: :responsible_body)

      expect(result.css('dd')[3].text).to include('The trust orders devices')
    end

    it 'does not show the school contact even if the school contact is set' do
      create(:preorder_information,
             school: school,
             who_will_order_devices: :responsible_body,
             school_contact: headteacher)

      expect(result.css('dl').text).not_to include('School contact')
    end
  end
end
