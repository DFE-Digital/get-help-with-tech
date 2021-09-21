require 'rails_helper'

RSpec.describe School, type: :model do
  it { is_expected.to be_versioned }

  describe 'validating URN' do
    it { is_expected.to allow_value('123456').for(:urn) }
    it { is_expected.not_to allow_value('12345678').for(:urn) }
    it { is_expected.not_to allow_value('1234').for(:urn) }
    it { is_expected.not_to allow_value('1234-Q').for(:urn) }
    it { is_expected.to validate_presence_of(:urn).with_message('Enter the unique reference number') }
  end

  describe 'validating name' do
    it { is_expected.to allow_value('Big School').for(:name) }
    it { is_expected.to validate_presence_of(:name).with_message('Enter the name of the establishment') }
  end

  describe '#preorder_status_or_default' do
    subject(:school) { create(:school, :manages_orders) }

    context 'when the school has a preorder_information record with a status' do
      it 'returns the status from the preorder_information record' do
        expect(school.preorder_status_or_default).to eq('needs_contact')
      end
    end

    context 'when the school has a preorder_information record without a status' do
      it 'infers the status' do
        school.preorder_information.status = nil
        allow(school.preorder_information).to receive(:infer_status).and_return('inferred_status')

        expect(school.preorder_status_or_default).to eq('inferred_status')
      end
    end

    context 'when the school has no preorder status and the responsible_body is set to manage orders centrally' do
      let(:responsible_body) { create(:local_authority, :manages_centrally) }

      subject(:school) { create(:school, responsible_body: responsible_body) }

      it 'returns "needs_info"' do
        expect(school.preorder_status_or_default).to eq('needs_info')
      end
    end

    context 'when the school has no preorder status and the responsible_body is set to schools managing orders' do
      let(:responsible_body) { create(:local_authority, :devolves_management) }

      subject(:school) { create(:school, responsible_body: responsible_body) }

      it 'returns "needs_contact"' do
        expect(school.preorder_status_or_default).to eq('needs_contact')
      end
    end
  end

  describe '#school_type' do
    subject { school.school_type }

    context 'for a special school' do
      let(:school) { build(:school, establishment_type: :special) }

      it { is_expected.to eq('special_school') }
    end

    context 'when the school is not a special school and the phase is primary' do
      let(:school) { build(:school, establishment_type: :academy, phase: :primary) }

      it { is_expected.to eq('primary_school') }
    end

    context 'when the school is not a special school and the phase is sixteen_plus' do
      let(:school) { build(:school, establishment_type: :local_authority, phase: :sixteen_plus) }

      it { is_expected.to eq('sixteen_plus_school') }
    end

    context 'when the school is not a special school and the phase is not set' do
      let(:school) { build(:school, establishment_type: :academy, phase: :phase_not_applicable) }

      it { is_expected.to be_blank }
    end
  end

  describe 'independent_special_school?' do
    let(:independent_special_school) { build(:iss_provision) }
    let(:social_care_leaver) { build(:scl_provision) }

    specify { expect(independent_special_school).to be_an_independent_special_school }
    specify { expect(social_care_leaver).not_to be_an_independent_special_school }
  end

  describe 'social_care_leaver?' do
    let(:social_care_leaver) { build(:scl_provision) }
    let(:independent_special_school) { build(:iss_provision) }

    specify { expect(social_care_leaver).to be_a_social_care_leaver }
    specify { expect(independent_special_school).not_to be_a_social_care_leaver }
  end

  describe '#has_laptop_allocation?' do
    let(:school) { create(:school) }

    context 'when there is no standard device allocation' do
      it 'is false' do
        expect(school.has_laptop_allocation?).to eq(false)
      end
    end

    context 'when there is a standard device allocation of the given type but the value is 0' do
      before do
        school.device_allocations << build(:school_device_allocation, device_type: 'std_device', allocation: 0)
      end

      it 'is false' do
        expect(school.has_laptop_allocation?).to eq(false)
      end
    end

    context 'when there is a standard device allocation' do
      before do
        school.device_allocations << build(:school_device_allocation, device_type: 'std_device', allocation: 1)
      end

      it 'is true' do
        expect(school.has_laptop_allocation?).to eq(true)
      end
    end

    context 'when there is a comms device allocation' do
      before do
        school.device_allocations << build(:school_device_allocation, device_type: 'coms_device', allocation: 1)
      end

      it 'is false' do
        expect(school.has_laptop_allocation?).to eq(false)
      end
    end
  end

  describe '#can_order_devices_right_now?' do
    let(:school) { create(:school, :in_lockdown) }

    context 'when there is no allocation of the given type' do
      it 'is false' do
        expect(school.can_order_devices_right_now?).to be_falsey
      end
    end

    context 'when there is an allocation of the given type with cap = devices_ordered' do
      let(:cap) { 0 }
      let(:devices_ordered) { 0 }

      before do
        school.device_allocations << build(:school_device_allocation, device_type: 'std_device', cap: cap, devices_ordered: devices_ordered)
      end

      it 'is false' do
        expect(school.can_order_devices_right_now?).to be_falsey
      end
    end

    context 'when there is an allocation of the given type with cap > devices_ordered' do
      let(:cap) { 2 }
      let(:devices_ordered) { 1 }
      let(:allocation) { 3 }

      before do
        school.device_allocations << build(:school_device_allocation,
                                           device_type: 'std_device',
                                           cap: cap,
                                           allocation: allocation,
                                           devices_ordered: devices_ordered)
      end

      it 'is true' do
        expect(school.can_order_devices_right_now?).to be_truthy
      end
    end

    context 'when there is an allocation of the given type with cap equals devices_ordered' do
      let(:cap) { 2 }
      let(:devices_ordered) { 2 }
      let(:allocation) { 3 }

      before do
        school.device_allocations << create(:school_device_allocation,
                                            school: school,
                                            device_type: 'std_device',
                                            cap: cap,
                                            allocation: allocation,
                                            devices_ordered: devices_ordered)
      end

      it 'is false' do
        expect(school.can_order_devices_right_now?).to be_falsey
      end
    end
  end

  describe '#invite_school_contact' do
    context "when the school contact isn't a user on the system" do
      let(:school_contact) do
        create(:school_contact,
               email_address: 'jsmith@school.sch.gov.uk',
               full_name: 'Jane Smith',
               school: school)
      end

      subject(:school) { create(:school, :manages_orders) }

      before do
        school.set_current_contact!(school_contact)
      end

      it 'creates a new user from the contact details' do
        expect { school.invite_school_contact }
          .to change { User.count }.from(0).to(1)

        invited_user = User.last
        expect(invited_user.email_address).to eq('jsmith@school.sch.gov.uk')
        expect(invited_user.full_name).to eq('Jane Smith')
        expect(invited_user.orders_devices).to be_truthy
        expect(invited_user.is_school_user?).to be_truthy
        expect(invited_user.school).to eq(school)
      end

      it 'sends an invitation email to the school user' do
        expect { school.invite_school_contact }
          .to(have_enqueued_job(ActionMailer::MailDeliveryJob)
          .once
          .with do |mailer_name, mailer_action, _, params|
            expect(mailer_name).to eq('InviteSchoolUserMailer')
            expect(mailer_action).to eq('nominated_contact_email')
            expect(params[:params][:user].email_address).to eq('jsmith@school.sch.gov.uk')
          end)
      end

      it 'updates the status' do
        expect { school.invite_school_contact }
          .to change { school.reload.device_ordering_status }.from('school_will_be_contacted').to('school_contacted')
      end
    end

    context 'when the school has no preorder information' do
      subject(:school) { build(:school) }

      it 'does nothing' do
        expect { school.invite_school_contact }
          .not_to change { User.count }.from(0)
      end
    end

    context "when there isn't any contact specified yet" do
      subject(:school) do
        build_stubbed(:school, :manages_orders)
      end

      it 'does nothing' do
        expect { school.invite_school_contact }
          .not_to change { User.count }.from(0)
      end
    end

    context 'when the school contact matches an existing user' do
      let(:school_contact) { create(:school_contact, email_address: 'jsmith@school.sch.gov.uk') }

      subject(:school) { create(:school, :manages_orders) }

      before do
        school.set_current_contact!(school_contact)
        create(:user, email_address: 'jsmith@school.sch.gov.uk')
      end

      it 'does nothing' do
        expect { school.invite_school_contact }
          .not_to change { User.count }.from(1)
      end
    end
  end

  describe '#who_will_order_devices' do
    let(:local_authority) { build(:local_authority, :manages_centrally) }

    context 'when the school has a preorder_information' do
      subject(:school) { build(:school, :manages_orders, :la_maintained, responsible_body: local_authority) }

      it 'returns the who_will_order_devices value from the preorder_information' do
        expect(school.who_will_order_devices).to eq('school')
      end
    end

    context 'when the school does not have a preorder_information' do
      subject(:school) { build(:school, :la_maintained, responsible_body: local_authority) }

      it 'returns the who_will_order_devices value from the responsible_body' do
        expect(school.who_will_order_devices).to eq('responsible_body')
      end
    end
  end

  describe '#active_responsible_users' do
    let!(:local_authority) { create(:local_authority) }
    let!(:school_user_who_has_signed_in) { create(:school_user, :signed_in_before, school: school) }
    let!(:responsible_body_user_who_has_signed_in) { create(:local_authority_user, :signed_in_before, responsible_body: local_authority) }

    context 'when the school will order their own devices' do
      subject(:school) { create(:school, :la_maintained, :manages_orders, responsible_body: local_authority) }

      before do
        create(:school_user, :never_signed_in, school: school)
      end

      it 'returns the school users who have signed in' do
        expect(school.active_responsible_users).to eq([school_user_who_has_signed_in])
      end
    end

    context 'when the school will have device orders placed centrally' do
      subject(:school) { create(:school, :la_maintained, :centrally_managed, responsible_body: local_authority) }

      before do
        create(:local_authority_user, :never_signed_in, responsible_body: local_authority)
      end

      it 'returns the responsible_body users who have signed in' do
        expect(school.active_responsible_users).to eq([responsible_body_user_who_has_signed_in])
      end
    end
  end

  describe '#in_virtual_cap_pool?' do
    subject(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }

    let(:schools) { create_list(:school, 2, :with_std_device_allocation, :with_coms_device_allocation, :manages_orders, :in_lockdown, responsible_body: responsible_body) }

    before do
      stub_computacenter_outgoing_api_calls
      first_school = schools.first
      first_school.orders_managed_centrally!
      first_school.std_device_allocation.update!(allocation: 10, cap: 10, devices_ordered: 2)
      first_school.coms_device_allocation.update!(allocation: 20, cap: 5, devices_ordered: 3)
    end

    it 'returns true for a school within the pool' do
      expect(schools.first.in_virtual_cap_pool?).to be true
    end

    it 'returns false for a school outside the pool' do
      expect(schools.last.in_virtual_cap_pool?).to be false
    end
  end

  describe '#matching_name_or_urn_or_ukprn_or_provision_urn' do
    it 'returns schools with the provided URN' do
      matched_school = create(:school, urn: 123_456)
      create(:school, urn: 123_458) # non-matching school

      expect(School.matching_name_or_urn_or_ukprn_or_provision_urn(123_456)).to eq([matched_school])
    end

    it 'returns schools which match the name partially or exactly' do
      matched_school1 = create(:school, name: 'Southside')
      matched_school2 = create(:school, name: 'Southside Primary')
      create(:school, name: 'Northside') # non-matching school

      expect(School.matching_name_or_urn_or_ukprn_or_provision_urn('Southside')).to contain_exactly(matched_school1, matched_school2)
    end

    it 'returns LaFundedPlaces matching the provided URN' do
      matched_school = create(:iss_provision, provision_urn: 'ISS999')
      create(:school, urn: 123_458) # non-matching school

      expect(School.matching_name_or_urn_or_ukprn_or_provision_urn('ISS999')).to eq([matched_school])
    end
  end

  describe '#can_invite_users?' do
    context 'RB orders' do
      subject(:school) { build_stubbed(:school, :centrally_managed) }

      it 'returns false' do
        expect(school.can_invite_users?).to be_falsey
      end
    end

    context 'school orders' do
      subject(:school) { build_stubbed(:school, :manages_orders) }

      it 'returns true' do
        expect(school.can_invite_users?).to be_truthy
      end
    end

    context 'we do not know who orders' do
      subject(:school) { build_stubbed(:school) }

      it 'returns true' do
        expect(school.can_invite_users?).to be_truthy
      end
    end
  end

  describe '#computacenter_references?' do
    subject(:school) { build(:school) }

    context 'when computacenter have set a ship-to reference' do
      before do
        school.computacenter_reference = '87654321'
      end

      it 'returns true' do
        expect(school.computacenter_references?).to be true
      end
    end

    context 'when computacenter have not set a ship-to reference' do
      before do
        school.computacenter_reference = nil
      end

      it 'returns false' do
        expect(school.computacenter_references?).to be false
      end
    end
  end

  describe 'can_change_who_manages_orders?' do
    context 'when the school is centrally managed and the responsible body has virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap_feature_flag: true) }
      let(:school) { create(:school, :centrally_managed, responsible_body: local_authority) }

      it 'returns false' do
        expect(school.can_change_who_manages_orders?).to be false
      end
    end

    context 'when the school is centrally managed and the responsible body does not have virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap_feature_flag: false) }
      let(:school) { create(:school, :centrally_managed, responsible_body: local_authority) }

      it 'returns true' do
        expect(school.can_change_who_manages_orders?).to be true
      end
    end

    context 'when the school manages orders and the responsible body has virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap_feature_flag: true) }
      let(:school) { create(:school, :manages_orders, responsible_body: local_authority) }

      it 'returns true' do
        expect(school.can_change_who_manages_orders?).to be true
      end
    end

    context 'when the school manages orders and the responsible body has does not have virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap_feature_flag: false) }
      let(:school) { create(:school, :manages_orders, responsible_body: local_authority) }

      it 'returns true' do
        expect(school.can_change_who_manages_orders?).to be true
      end
    end
  end

  describe 'change_who_manages_orders!' do
    context 'when the school is centrally managed and the responsible body has virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap_feature_flag: true) }
      let(:school) { create(:school, :centrally_managed, responsible_body: local_authority) }

      it 'raises an error' do
        expect { school.change_who_manages_orders!(:school) }.to raise_error(VirtualCapPoolError)
      end
    end

    context 'when the school is centrally managed and the responsible body does not have virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap_feature_flag: false) }
      let(:school) { create(:school, :centrally_managed, responsible_body: local_authority) }

      it 'changes who can order' do
        school.change_who_manages_orders!(:school)
        expect(school.reload.orders_managed_by_school?).to be_truthy
      end
    end

    context 'when the school manages orders and the responsible body has virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap_feature_flag: true) }
      let(:school) { create(:school, :manages_orders, :can_order, :with_std_device_allocation, responsible_body: local_authority) }

      it 'changes who can order' do
        school.change_who_manages_orders!(:responsible_body)
        expect(school.reload.orders_managed_centrally?).to be_truthy
      end

      it 'adds the school to the virtual cap pool' do
        school.change_who_manages_orders!(:responsible_body)
        expect(school.reload.in_virtual_cap_pool?).to be_truthy
      end
    end

    context 'when the school manages orders and the responsible body has does not have virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap_feature_flag: false) }
      let(:school) { create(:school, :manages_orders, responsible_body: local_authority) }

      it 'changes who can order' do
        school.change_who_manages_orders!(:responsible_body)
        expect(school.reload.orders_managed_centrally?).to be_truthy
      end
    end
  end
end
