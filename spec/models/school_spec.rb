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

  describe '.with_restricted_devices_and_users' do
    let!(:school) { create(:school) }

    context 'when the school has no restricted devices' do
      before { create(:school_user, school:) }

      specify { expect(School.with_restricted_devices_and_users).to be_blank }
    end

    context 'when the school has no users associated' do
      before { create(:asset, setting: school) }

      specify { expect(School.with_restricted_devices_and_users).to be_blank }
    end

    context 'when the school has restricted devices and users associated but opting-out for restricted devices comms' do
      before do
        create(:asset, setting: school)
        create(:school_user, school:, restricted_devices_comms_opt_out: true)
      end

      specify { expect(School.with_restricted_devices_and_users).to be_blank }
    end

    context 'when the school has restricted devices and users associated not opting-out for restricted devices comms' do
      before do
        create(:asset, setting: school)
        create(:school_user, school:)
      end

      specify { expect(School.with_restricted_devices_and_users).to include(school) }
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

  describe '#has_allocation?' do
    let(:school) { create(:school) }

    context 'when there is 0 allocation' do
      it 'is false' do
        expect(school).not_to have_allocation(:laptop)
        expect(school).not_to have_allocation(:router)
      end
    end

    context 'when there is positive allocation' do
      before do
        school.raw_laptop_allocation = 1
        school.raw_router_allocation = 2
      end

      it 'is true' do
        expect(school).to have_allocation(:laptop)
        expect(school).to have_allocation(:router)
      end
    end

    context 'when there is allocation only for one device type' do
      before do
        school.raw_router_allocation = 1
      end

      it 'is true for the positive type' do
        expect(school).to have_allocation(:router)
      end

      it 'is false for the non positive type' do
        expect(school).not_to have_allocation(:laptop)
      end
    end
  end

  describe '#can_order_devices_right_now?' do
    let(:school) { create(:school, :in_lockdown) }

    before do
      school.raw_laptop_allocation = allocation
      school.circumstances_laptops = circumstances_devices
      school.over_order_reclaimed_laptops = over_order_reclaimed_devices
      school.raw_laptops_ordered = devices_ordered
    end

    context 'when there is an allocation of the given type with cap = devices_ordered' do
      let(:allocation) { devices_ordered }
      let(:circumstances_devices) { 0 }
      let(:over_order_reclaimed_devices) { 0 }
      let(:devices_ordered) { 0 }

      it 'is false' do
        expect(school.can_order_devices_right_now?).to be_falsey
      end
    end

    context 'when there is an allocation of the given type with cap > devices_ordered' do
      let(:allocation) { 3 }
      let(:circumstances_devices) { -1 }
      let(:over_order_reclaimed_devices) { 0 }
      let(:devices_ordered) { 1 }

      it 'is true' do
        expect(school.can_order_devices_right_now?).to be_truthy
      end
    end

    context 'when there is an allocation of the given type with cap equals devices_ordered' do
      let(:allocation) { 3 }
      let(:circumstances_devices) { -1 }
      let(:over_order_reclaimed_devices) { 0 }
      let(:devices_ordered) { 2 }

      it 'is false' do
        expect(school.can_order_devices_right_now?).to be_falsey
      end
    end
  end

  describe '#invite_school_contact' do
    before { stub_computacenter_outgoing_api_calls }

    context "when the school contact isn't a user on the system" do
      let(:school_contact) do
        create(:school_contact,
               email_address: 'jsmith@school.sch.gov.uk',
               full_name: 'Jane Smith',
               school:)
      end

      subject(:school) { create(:school, :manages_orders) }

      before do
        school.set_school_contact!(school_contact)
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
          .to change { school.reload.preorder_status }.from('school_will_be_contacted').to('school_contacted')
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
        school.set_school_contact!(school_contact)
        create(:user, email_address: 'jsmith@school.sch.gov.uk')
      end

      it 'does nothing' do
        expect { school.invite_school_contact }
          .not_to change { User.count }.from(1)
      end
    end
  end

  describe '#active_responsible_users' do
    let!(:local_authority) { create(:local_authority) }
    let!(:school_user_who_has_signed_in) { create(:school_user, :signed_in_before, school:) }
    let!(:responsible_body_user_who_has_signed_in) { create(:local_authority_user, :signed_in_before, responsible_body: local_authority) }

    context 'when the school will order their own devices' do
      subject(:school) { create(:school, :la_maintained, :manages_orders, responsible_body: local_authority) }

      before do
        create(:school_user, :never_signed_in, school:)
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

  describe '#vcap?' do
    subject(:responsible_body) { create(:trust, :manages_centrally, :vcap) }

    let(:schools) do
      create_list(:school,
                  2,
                  :manages_orders,
                  :in_lockdown,
                  responsible_body:,
                  laptops: [1, 0, 0],
                  routers: [1, 0, 0])
    end

    before do
      stub_computacenter_outgoing_api_calls
      SchoolSetWhoManagesOrdersService.new(schools.first, :responsible_body).call
      UpdateSchoolDevicesService.new(school: schools.first,
                                     laptop_allocation: 10,
                                     over_order_reclaimed_laptops: 0,
                                     laptops_ordered: 2,
                                     router_allocation: 20,
                                     over_order_reclaimed_routers: -15,
                                     routers_ordered: 3).call
    end

    it 'returns true for a school within the pool' do
      expect(schools.first.vcap?).to be true
    end

    it 'returns false for a school outside the pool' do
      expect(schools.last.vcap?).to be false
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
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap: true) }
      let(:school) { create(:school, :centrally_managed, responsible_body: local_authority) }

      it 'returns false' do
        expect(school.can_change_who_manages_orders?).to be false
      end
    end

    context 'when the school is centrally managed and the responsible body does not have virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap: false) }
      let(:school) { create(:school, :centrally_managed, responsible_body: local_authority) }

      it 'returns true' do
        expect(school.can_change_who_manages_orders?).to be true
      end
    end

    context 'when the school manages orders and the responsible body has virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap: true) }
      let(:school) { create(:school, :manages_orders, responsible_body: local_authority) }

      it 'returns true' do
        expect(school.can_change_who_manages_orders?).to be true
      end
    end

    context 'when the school manages orders and the responsible body has does not have virtual caps enabled' do
      let(:local_authority) { create(:local_authority, :manages_centrally, vcap: false) }
      let(:school) { create(:school, :manages_orders, responsible_body: local_authority) }

      it 'returns true' do
        expect(school.can_change_who_manages_orders?).to be true
      end
    end
  end

  describe 'laptops_ordered_in_the_past' do
    let(:cap_used) { 30 }
    let(:programme_dates) { Settings.programme.map { |(_, props)| Date.parse(props.start_date) }.sort }

    subject(:school) { build(:school) }

    context 'when no laptops ordered in the past' do
      it 'returns 0' do
        expect(school.laptops_ordered_in_the_past).to eq(0)
      end
    end

    context 'when laptops ordered only in the current wave' do
      before do
        create(:devices_ordered_update,
               :laptop,
               created_at: programme_dates.last + 1.day,
               cap_used:,
               ship_to: school.ship_to)
      end

      it 'returns 0' do
        expect(school.laptops_ordered_in_the_past).to eq(0)
      end
    end

    context 'when laptops ordered in a past wave' do
      before do
        create(:devices_ordered_update,
               :laptop,
               created_at: programme_dates.first - 1.day,
               cap_used:,
               ship_to: school.ship_to)
      end

      it 'returns the laptops ordered in previous programme waves' do
        expect(school.laptops_ordered_in_the_past).to eq(cap_used)
      end
    end

    context 'when laptops ordered in past waves' do
      before do
        create(:devices_ordered_update,
               :laptop,
               created_at: programme_dates.first,
               cap_used:,
               ship_to: school.ship_to)
        create(:devices_ordered_update,
               :laptop,
               created_at: programme_dates.first - 1.day,
               cap_used:,
               ship_to: school.ship_to)
      end

      it 'returns the laptops ordered in previous programme waves' do
        expect(school.laptops_ordered_in_the_past).to eq(cap_used * 2)
      end
    end

    context 'when laptops ordered several times in past waves' do
      before do
        create(:devices_ordered_update,
               :laptop,
               created_at: programme_dates.first,
               cap_used: (cap_used / 2),
               ship_to: school.ship_to)
        create(:devices_ordered_update,
               :laptop,
               created_at: programme_dates.first + 1.day,
               cap_used:,
               ship_to: school.ship_to)
        create(:devices_ordered_update,
               :laptop,
               created_at: programme_dates.first - 1.day,
               cap_used:,
               ship_to: school.ship_to)
      end

      it 'returns the laptops ordered in previous programme waves' do
        expect(school.laptops_ordered_in_the_past).to eq(cap_used * 2)
      end
    end
  end
end
