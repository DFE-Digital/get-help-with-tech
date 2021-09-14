require 'rails_helper'

describe ResponsibleBody::SchoolDetailsSummaryListComponent do
  include Rails.application.routes.url_helpers

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

      create(:school_device_allocation, school: school, device_type: 'std_device', cap: 1, allocation: 100)
    end

    it 'confirms that fact' do
      expect(result.css('.govuk-summary-list__row')[1].text).to include('The school or college orders devices')
    end

    it 'renders the school allocation' do
      expect(result.css('.govuk-summary-list__row')[2].text).to include('100 devices')
    end

    it 'renders the school type' do
      expect(value_for_row(result, 'Setting').text).to include('Primary school')
    end

    it 'renders the school details' do
      expect(value_for_row(result, 'Status').text).to include('School will be contacted')
    end

    it 'shows the chromebook details without links to change it' do
      expect(value_for_row(result, 'Ordering Chromebooks?').text).to include('Yes')
      expect(value_for_row(result, 'Domain').text).to include('school.domain.org')
      expect(value_for_row(result, 'Recovery email').text).to include('admin@recovery.org')
    end

    context "when the school isn't under lockdown restrictions or has any shielding children" do
      before do
        school.cannot_order!
      end

      it 'cannot place orders' do
        expect(value_for_row(result, 'Can place orders?').text).to include('Not yet because no closure or group of self-isolating children has been reported')
      end
    end

    context 'when the school is under lockdown restrictions' do
      before do
        school.can_order!
      end

      it 'can place orders' do
        expect(value_for_row(result, 'Can place orders?').text).to include('Yes, a closure or group of self-isolating children has been reported')
      end
    end

    context 'when the school can order devices for specific circumstances' do
      before do
        school.can_order_for_specific_circumstances!
      end

      it 'can place orders' do
        expect(value_for_row(result, 'Can place orders?').text).to include('Yes, for specific circumstances')
      end
    end

    context 'and the headteacher has been set as the school contact' do
      it 'displays the headteacher details' do
        create(:preorder_information,
               school: school,
               who_will_order_devices: :school,
               school_contact: headteacher)

        expect(value_for_row(result, 'School contact').text).to include('Headteacher: Davy Jones')
        expect(value_for_row(result, 'School contact').text).to include('davy.jones@school.sch.uk')
        expect(value_for_row(result, 'School contact').text).to include('12345')
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

        expect(value_for_row(result, 'School contact').text).to include('Jane Smith')
        expect(value_for_row(result, 'School contact').text).to include('abc@example.com')
        expect(value_for_row(result, 'School contact').text).to include('12345')
      end
    end
  end

  context 'when the responsible body will place device orders' do
    let(:rb) { create(:trust, :manages_centrally, :vcap_feature_flag) }
    let(:school) { create(:school, :primary, :academy, :centrally_managed, responsible_body: rb) }

    it 'confirms that fact' do
      expect(value_for_row(result, 'Who will order?').text).to include('The trust orders devices')
    end

    it 'shows the chromebook details with links to change it' do
      school.preorder_information.update(
        school_or_rb_domain: 'school.domain.org',
        recovery_email_address: 'admin@recovery.org',
        will_need_chromebooks: 'yes'
      )

      expect(value_for_row(result, 'Ordering Chromebooks?').text).to include('Yes')
      expect(action_for_row(result, 'Ordering Chromebooks?').text).to include('Change')

      expect(value_for_row(result, 'Domain').text).to include('school.domain.org')
      expect(action_for_row(result, 'Domain').text).to include('Change')

      expect(value_for_row(result, 'Recovery email').text).to include('admin@recovery.org')
      expect(action_for_row(result, 'Recovery email').text).to include('Change')
    end

    it 'does not show the school contact even if the school contact is set' do
      school.preorder_information.update!(school_contact: headteacher)
      expect(result.css('dl').text).not_to include('School contact')
    end

    context 'when the responsible body has virtual caps enabled' do
      context 'when the school manages orders' do
        let(:school) { create(:school, :primary, :academy, :manages_orders, responsible_body: rb) }

        it 'confirms that fact and allow changes' do
          expect(value_for_row(result, 'Who will order?').text).to include('The school or college orders devices')
          expect(action_for_row(result, 'Who will order?').text).to include('Change')
        end
      end

      context 'when the school is centrally managed' do
        let(:school) { create(:school, :primary, :academy, :centrally_managed, responsible_body: rb) }

        it 'confirms that fact but does not allow changes' do
          expect(value_for_row(result, 'Who will order?').text).to include('The trust orders devices')
          expect(action_for_row(result, 'Who will order?')).to be_nil
        end
      end
    end
  end

  context 'when the responsible body has not made a decision about who will order' do
    it 'confirms that fact and provides a link to make the decision' do
      expect(value_for_row(result, 'Who will order?').text).to include("#{school.responsible_body.name} hasn’t decided this yet")
      expect(action_for_row(result, 'Who will order?').text).to include('Decide who will order')
      expect(action_for_row(result, 'Who will order?').css('a').attr('href').value).to eq(responsible_body_devices_who_will_order_edit_path)
    end
  end

  describe 'devices ordered count' do
    context 'when no devices ordered' do
      it 'does not show devices ordered row' do
        expect(result.text).not_to include('Devices ordered')
      end
    end

    context 'when devices_ordered > 0' do
      before do
        alloc = school.build_std_device_allocation(devices_ordered: 3, cap: 100, allocation: 100)
        alloc.save!
      end

      context 'when the school is not in a virtual_cap_pool' do
        before do
          allow(school).to receive(:in_virtual_cap_pool?).and_return(false)
          allow(school.responsible_body).to receive(:has_virtual_cap_feature_flags?).and_return(false)
        end

        it 'shows devices ordered row with count' do
          expect(value_for_row(result, 'Devices ordered').text).to include('3 devices')
        end
      end

      context 'when the responsible body is not in the virtual cap' do
        before do
          allow(school).to receive(:in_virtual_cap_pool?).and_return(true)
          allow(school.responsible_body).to receive(:has_virtual_cap_feature_flags?).and_return(false)
        end

        it 'shows devices ordered row with count' do
          expect(value_for_row(result, 'Devices ordered').text).to include('3 devices')
        end
      end

      context 'when the school is in a virtual_cap_pool' do
        before do
          allow(school).to receive(:in_virtual_cap_pool?).and_return(true)
          allow(school.responsible_body).to receive(:has_virtual_cap_feature_flags?).and_return(true)
        end

        it 'does not show devices ordered row' do
          expect(result.text).not_to include('Devices ordered')
        end
      end
    end
  end

  describe 'routers ordered count' do
    context 'when no routers ordered' do
      it 'does not show routers ordered row' do
        expect(result.text).not_to include('Routers ordered')
      end
    end

    context 'when routers_ordered > 0' do
      before do
        alloc = school.build_coms_device_allocation(devices_ordered: 3, cap: 100, allocation: 100)
        alloc.save!
      end

      context 'when the school is not in a virtual_cap_pool' do
        before do
          allow(school).to receive(:in_virtual_cap_pool?).and_return(false)
          allow(school.responsible_body).to receive(:has_virtual_cap_feature_flags?).and_return(false)
        end

        it 'shows routers ordered row with count' do
          expect(value_for_row(result, 'Routers ordered').text).to include('3 routers')
        end
      end

      context 'when the responsible body is not in the virtual cap' do
        before do
          allow(school).to receive(:in_virtual_cap_pool?).and_return(true)
          allow(school.responsible_body).to receive(:has_virtual_cap_feature_flags?).and_return(false)
        end

        it 'shows routers ordered row with count' do
          expect(value_for_row(result, 'Routers ordered').text).to include('3 routers')
        end
      end

      context 'when the school is in a virtual_cap_pool' do
        before do
          allow(school).to receive(:in_virtual_cap_pool?).and_return(true)
          allow(school.responsible_body).to receive(:has_virtual_cap_feature_flags?).and_return(true)
        end

        it 'does not show routers ordered row' do
          expect(result.text).not_to include('Routers ordered')
        end
      end
    end
  end

  describe 'coms_device_allocation' do
    context 'when not present' do
      let(:school) { build(:school) }

      it 'does not show Router allocation' do
        expect(result.text).not_to include('Router allocation')
      end
    end

    context 'when zero' do
      let(:school) { build(:school, coms_device_allocation: coms_allocation) }
      let(:coms_allocation) { build(:school_device_allocation, :with_coms_allocation, allocation: 0) }

      it 'does not show Router allocation' do
        expect(result.text).not_to include('Router allocation')
      end
    end

    context 'when non-zero value present' do
      let(:school) { build(:school, coms_device_allocation: coms_allocation) }
      let(:coms_allocation) { build(:school_device_allocation, :with_coms_allocation) }

      it 'shows Router allocation' do
        expect(result.text).to include('Router allocation')
      end
    end
  end
end
