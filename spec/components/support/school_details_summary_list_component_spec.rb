require 'rails_helper'

describe Support::SchoolDetailsSummaryListComponent do
  let(:school) { create(:school, :primary, :la_maintained, contacts: [headteacher]) }
  let(:headteacher) do
    create(:school_contact, :headteacher,
           full_name: 'Davy Jones',
           email_address: 'davy.jones@school.sch.uk',
           phone_number: '12345')
  end

  let(:support_user) { build(:support_user) }

  subject(:result) { render_inline(described_class.new(school: school, viewer: support_user)) }

  it 'does not show school name' do
    expect(row_for_key(result, 'Name')).to be_nil
  end

  it 'does not show school responsible body' do
    expect(row_for_key(result, 'Responsible Body')).to be_nil
  end

  it 'does not show change link for headteacher' do
    expect(action_for_row(result, 'Headteacher')).to be_nil
  end

  context 'when third line support user' do
    let(:support_user) { build(:support_user, :third_line) }

    it 'shows school name' do
      expect(value_for_row(result, 'Name')).to be_nil
    end

    it 'shows change link for school name' do
      expect(action_for_row(result, 'Name')).to be_nil
    end

    it 'shows school responsible body' do
      expect(value_for_row(result, 'Responsible Body')).to be_nil
    end

    it 'shows change link for school responsible body' do
      expect(action_for_row(result, 'Responsible Body')).to be_nil
    end

    it 'shows change link for headteacher' do
      expect(action_for_row(result, 'Headteacher')).to be_nil
    end
  end

  context 'when the school will place device orders' do
    let(:school) do
      create(:school,
             :primary,
             :la_maintained,
             :manages_orders,
             contacts: [headteacher],
             school_or_rb_domain: 'school.domain.org',
             recovery_email_address: 'admin@recovery.org',
             will_need_chromebooks: 'yes',
             laptops: [3, 0, 0])
    end

    it 'confirms that fact' do
      expect(value_for_row(result, 'Who ordered?').text).to include('The school or college ordered devices')
    end

    it 'renders the school allocation' do
      expect(value_for_row(result, 'Device allocation').text).to include("#{school.raw_allocation(:laptop)} devices")
    end

    it 'renders the school type' do
      expect(value_for_row(result, 'Setting').text).to include('Primary school')
    end

    it 'renders the school details' do
      expect(value_for_row(result, 'Status').text).to include('Needs a contact')
    end

    it 'shows the chromebook details without links to change it' do
      expect(value_for_row(result, 'Ordered Chromebooks?').text).to include('Yes')
      expect(value_for_row(result, 'Domain').text).to include('school.domain.org')
      expect(value_for_row(result, 'Recovery email').text).to include('admin@recovery.org')
    end

    context "when the school isn't under lockdown restrictions or has any shielding children" do
      it 'cannot place orders' do
        expect(value_for_row(result, 'Could place orders?').text).to include('No')
      end
    end

    it 'displays the headteacher details' do
      expect(value_for_row(result, 'Headteacher').text).to include('Davy Jones')
      expect(value_for_row(result, 'Headteacher').text).to include('davy.jones@school.sch.uk')
      expect(value_for_row(result, 'Headteacher').text).to include('12345')
    end
  end

  context 'when the responsible body will place device orders' do
    let(:rb) { create(:trust, :manages_centrally, :vcap) }
    let(:school) { create(:school, :primary, :academy, :centrally_managed, responsible_body: rb) }

    it 'confirms that fact' do
      expect(result.css('.govuk-summary-list__row')[1].text).to include('The trust ordered devices')
    end

    it 'shows the chromebook details and allows them to be edited' do
      school.update_chromebook_information_and_status!(
        school_or_rb_domain: 'school.domain.org',
        recovery_email_address: 'admin@recovery.org',
        will_need_chromebooks: 'yes',
      )

      expect(value_for_row(result, 'Ordered Chromebooks?').text).to include('Yes')
      expect(value_for_row(result, 'Domain').text).to include('school.domain.org')
      expect(value_for_row(result, 'Recovery email').text).to include('admin@recovery.org')
    end

    it 'does not show the school contact even if the school contact is set' do
      school.set_school_contact!(headteacher)
      expect(result.css('dl').text).not_to include('School contact')
    end
  end

  context 'when a computacenter user is the viewer' do
    subject(:result) { render_inline(described_class.new(school: school, viewer: build(:computacenter_user))) }

    before do
      school.update!(who_will_order_devices: :responsible_body,
                     school_or_rb_domain: 'school.domain.org',
                     recovery_email_address: 'admin@recovery.org',
                     will_need_chromebooks: 'yes')
    end

    it 'shows the chromebook details and allows them to be edited' do
      expect(value_for_row(result, 'Ordered Chromebooks?').text).to include('Yes')
      expect(value_for_row(result, 'Domain').text).to include('school.domain.org')
      expect(value_for_row(result, 'Recovery email').text).to include('admin@recovery.org')
    end
  end

  context 'when the responsible body has not made a decision about who will order' do
    it 'confirms that fact' do
      expect(result.css('.govuk-summary-list__row')[1].text).to include("#{school.responsible_body.name} hasn’t decided this yet")
      expect(result.css('.govuk-summary-list__row')[1].text).not_to include('Set who ordered')
    end

    it 'displays the headteacher details if the headteacher is present' do
      expect(value_for_row(result, 'Headteacher').text).to include('Davy Jones')
      expect(value_for_row(result, 'Headteacher').text).to include('davy.jones@school.sch.uk')
      expect(value_for_row(result, 'Headteacher').text).to include('12345')
    end

    it 'displays Not Set if none are available' do
      school.contacts.destroy_all

      expect(value_for_row(result, 'Headteacher').text).to include('Not set')
    end
  end

  describe 'router_allocation' do
    context 'when zero' do
      let(:school) { build(:school) }

      it 'shows Router allocation' do
        expect(result.text).to include('Router allocation')
      end
    end

    context 'when non-zero value present' do
      let(:school) { build(:school, routers: [1, 0, 0]) }

      it 'shows Router allocation' do
        expect(result.text).to include('Router allocation')
      end
    end
  end

  describe 'address' do
    it 'is displayed' do
      expect(result.text).to include(school.address_1.to_s)
      expect(result.text).to include(school.address_2.to_s)
      expect(result.text).to include(school.address_3.to_s)
      expect(result.text).to include(school.town.to_s)
      expect(result.text).to include(school.county.to_s)
      expect(result.text).to include(school.postcode.to_s)
    end
  end

  describe 'computacenter soldTo' do
    it 'returns RB computacenter_reference' do
      expect(value_for_row(result, 'Computacenter SoldTo').text).to include(school.responsible_body.computacenter_reference)
    end

    context 'when not set' do
      before do
        school.responsible_body.update(computacenter_reference: nil)
      end

      it 'returns placeholder copy' do
        expect(value_for_row(result, 'Computacenter SoldTo').text).to include('Not present')
      end
    end
  end

  describe 'computacenter shipTo' do
    it 'returns school computacenter_reference' do
      expect(value_for_row(result, 'Computacenter ShipTo').text).to include(school.computacenter_reference)
    end

    context 'when not set' do
      before do
        school.update(computacenter_reference: nil)
      end

      it 'returns placeholder copy' do
        expect(value_for_row(result, 'Computacenter ShipTo').text).to include('Not present')
      end
    end
  end
end
