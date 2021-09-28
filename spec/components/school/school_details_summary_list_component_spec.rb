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
      expect(value_for_row(result, 'Device allocation').text).to include("#{school.std_device_allocation.raw_allocation} devices")
    end

    it 'renders the school type' do
      expect(value_for_row(result, 'Setting').text).to include('Primary school')
    end

    it 'shows the chromebook details with links to change it' do
      expect(value_for_row(result, 'Will you need to order Chromebooks?').text).to include('We need Chromebooks')
      expect(action_for_row(result, 'Will you need to order Chromebooks?').text).to include('Change')

      expect(value_for_row(result, 'Domain').text).to include('school.domain.org')
      expect(action_for_row(result, 'Domain').text).to include('Change')

      expect(value_for_row(result, 'Recovery email').text).to include('admin@recovery.org')
      expect(action_for_row(result, 'Recovery email').text).to include('Change')
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
      expect(value_for_row(result, 'Will you need to order Chromebooks?').text).to include('We need Chromebooks')
      expect(action_for_row(result, 'Will you need to order Chromebooks?')).not_to be_present

      expect(value_for_row(result, 'Domain').text).to include('school.domain.org')
      expect(action_for_row(result, 'Domain')).not_to be_present

      expect(value_for_row(result, 'Recovery email').text).to include('admin@recovery.org')
      expect(action_for_row(result, 'Recovery email')).not_to be_present
    end
  end

  describe 'router allocation' do
    context 'when there is no allocation' do
      it 'does not show router allocation' do
        expect(result.text).not_to include('Router allocation')
      end
    end

    context 'when there is a zero allocation' do
      before do
        create(:school_device_allocation, :with_coms_allocation, allocation: 0, school: school)
      end

      it 'does not show router allocation' do
        expect(result.text).not_to include('Router allocation')
      end
    end

    context 'when there is a non-zero allocation' do
      before do
        create(:school_device_allocation, :with_coms_allocation, school: school)
      end

      it 'shows router allocation' do
        expect(result.text).to include('Router allocation')
      end
    end
  end
end
