require 'rails_helper'

describe Support::SchoolDetailsSummaryListComponent do
  let(:school) { create(:school, :primary, :la_maintained, contacts: [headteacher]) }
  let(:headteacher) do
    create(:school_contact, :headteacher,
           full_name: 'Davy Jones',
           email_address: 'davy.jones@school.sch.uk',
           phone_number: '12345')
  end

  subject(:result) { render_inline(described_class.new(school: school)) }

  context 'when the school will place device orders' do
    before do
      create(:preorder_information,
             school: school,
             who_will_order_devices: :school,
             school_or_rb_domain: 'school.domain.org',
             recovery_email_address: 'admin@recovery.org',
             will_need_chromebooks: 'yes')

      create(:school_device_allocation, school: school, device_type: 'std_device', allocation: 3)
    end

    it 'confirms that fact' do
      expect(result.css('.govuk-summary-list__row')[1].text).to include('The school orders devices')
    end

    it 'renders the school allocation' do
      expect(result.css('.govuk-summary-list__row')[2].text).to include('3 devices')
    end

    it 'renders the school type' do
      expect(result.css('.govuk-summary-list__row')[4].text).to include('Primary school')
    end

    it 'renders the school details' do
      expect(result.css('.govuk-summary-list__row')[0].text).to include('Needs a contact')
    end

    it 'shows the chromebook details without links to change it' do
      expect(result.css('.govuk-summary-list__row')[5].text).to include('Yes, we will order Chromebooks')
      expect(result.css('.govuk-summary-list__row')[6].text).to include('school.domain.org')
      expect(result.css('.govuk-summary-list__row')[7].text).to include('admin@recovery.org')
    end

    context "when the school isn't under lockdown restrictions or has any shielding children" do
      it 'cannot place orders' do
        expect(result.css('.govuk-summary-list__row')[3].text).to include('Not yet because there are no local coronavirus')
      end
    end

    it 'displays the headteacher details' do
      create(:preorder_information,
             school: school,
             who_will_order_devices: :school)

      expect(result.css('.govuk-summary-list__row')[6].text).to include('Headteacher')
      expect(result.css('.govuk-summary-list__row')[6].inner_html).to include('Davy Jones<br>davy.jones@school.sch.uk<br>12345')
    end
  end

  context 'when the responsible body will place device orders' do
    let(:school) { create(:school, :primary, :academy) }

    before do
      create(:preorder_information,
             school: school,
             who_will_order_devices: :responsible_body,
             school_or_rb_domain: 'school.domain.org',
             recovery_email_address: 'admin@recovery.org',
             will_need_chromebooks: 'yes',
             school_contact: headteacher)
    end

    it 'confirms that fact' do
      create(:preorder_information, school: school, who_will_order_devices: :responsible_body)

      expect(result.css('.govuk-summary-list__row')[1].text).to include('The trust orders devices')
    end

    it 'shows the chromebook details' do
      expect(result.css('.govuk-summary-list__row')[5].text).to include('Yes, we will order Chromebooks')
      expect(result.css('.govuk-summary-list__row')[6].text).to include('school.domain.org')
      expect(result.css('.govuk-summary-list__row')[7].text).to include('admin@recovery.org')

      expect(result.css('.govuk-summary-list__row')[5].css('a')).not_to be_present
      expect(result.css('.govuk-summary-list__row')[6].css('a')).not_to be_present
      expect(result.css('.govuk-summary-list__row')[7].css('a')).not_to be_present
    end

    it 'does not show the school contact even if the school contact is set' do
      expect(result.css('dl').text).not_to include('School contact')
    end
  end

  context 'when the responsible body has not made a decision about who will order' do
    it 'confirms that fact' do
      expect(result.css('.govuk-summary-list__row')[1].text).to include("#{school.responsible_body.name} hasn’t decided this yet")
      expect(result.css('.govuk-summary-list__row')[1].text).not_to include('Decide who will order')
    end

    it 'displays the headteacher details if the headteacher is present' do
      expect(result.css('.govuk-summary-list__row')[5].text).to include('Headteacher')
      expect(result.css('.govuk-summary-list__row')[5].inner_html).to include('Davy Jones<br>davy.jones@school.sch.uk<br>12345')
    end

    it 'hides the headteacher details if none are available' do
      school.contacts.destroy_all

      expect(result.css('.govuk-summary-list__row').text).not_to include('Headteacher')
    end
  end
end
