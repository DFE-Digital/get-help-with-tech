require 'rails_helper'

describe School::SchoolDetailsSummaryListComponent do
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
      create(:preorder_information,
             school: school,
             who_will_order_devices: :school,
             school_or_rb_domain: 'school.domain.org',
             recovery_email_address: 'admin@recovery.org',
             will_need_chromebooks: 'yes',
             school_contact: headteacher)

      create(:school_device_allocation, school: school, device_type: 'std_device', allocation: 3)
    end

    it 'renders the school allocation' do
      expect(result.css('dd')[0].text).to include('3 devices')
    end

    it 'renders the school type' do
      expect(result.css('dd')[1].text).to include('Primary school')
    end

    it 'shows the chromebook details with links to change it' do
      expect(result.css('dd')[2].text).to include('Yes')
      expect(result.css('dd')[3].text).to include('Change')
      expect(result.css('dd')[4].text).to include('school.domain.org')
      expect(result.css('dd')[5].text).to include('Change')
      expect(result.css('dd')[6].text).to include('admin@recovery.org')
      expect(result.css('dd')[7].text).to include('Change')
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

    it 'does not show the school contact even if the school contact is set' do
      expect(result.css('dl').text).not_to include('School contact')
    end

    it 'shows the chromebook details without links to change it' do
      expect(result.css('dd')[2].text).to include('Yes')
      expect(result.css('dd')[3].text).to include('school.domain.org')
      expect(result.css('dd')[4].text).to include('admin@recovery.org')
    end
  end
end
