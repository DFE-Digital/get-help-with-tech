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
    let(:school) do
      create(:school,
             :primary,
             :la_maintained,
             :manages_orders,
             school_or_rb_domain: 'school.domain.org',
             recovery_email_address: 'admin@recovery.org',
             will_need_chromebooks: 'yes',
             school_contact: headteacher,
             laptops: [3, 0, 0])
    end

    it 'renders the school allocation' do
      expect(value_for_row(result, 'Device allocation').text).to include("#{school.raw_allocation(:laptop)} devices")
    end

    it 'renders the school type' do
      expect(value_for_row(result, 'Setting').text).to include('Primary school')
    end
  end

  context 'when the responsible body will place device orders' do
    let(:rb) { create(:trust, :manages_centrally, :vcap) }
    let(:school) { create(:school, :primary, :academy, :centrally_managed, responsible_body: rb) }

    it 'does not show the school contact even if the school contact is set' do
      school.set_school_contact!(headteacher)
      expect(result.css('dl').text).not_to include('School contact')
    end
  end
end
