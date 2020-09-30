require 'rails_helper'

RSpec.describe School, type: :model do
  describe 'validating URN' do
    let(:school) { subject }

    context 'the URN is 6 digits' do
      before do
        school.urn = '123456'
      end

      it 'is valid' do
        school.valid?
        expect(school.errors).not_to have_key(:urn)
      end
    end

    context 'the URN has more than 6 digits' do
      before do
        school.urn = '123456012'
      end

      it 'is not valid' do
        school.valid?
        expect(school.errors).to have_key(:urn)
        expect(school.errors[:urn]).to include('The URN must be 6 digits')
      end
    end

    context 'the URN has less than 6 digits' do
      before do
        school.urn = '1234'
      end

      it 'is not valid' do
        school.valid?
        expect(school.errors).to have_key(:urn)
        expect(school.errors[:urn]).to include('The URN must be 6 digits')
      end
    end

    context 'the URN contains non-numeric characters' do
      before do
        school.urn = '1234-Q'
      end

      it 'is not valid' do
        school.valid?
        expect(school.errors).to have_key(:urn)
        expect(school.errors[:urn]).to include('The URN must be 6 digits')
      end
    end

    context 'a URN is blank' do
      before do
        school.urn = nil
      end

      it 'is not valid' do
        school.valid?
        expect(school.errors).to have_key(:urn)
        expect(school.errors[:urn]).to include('Enter the unique reference number')
      end
    end
  end

  describe 'validating name' do
    context 'when a name is supplied' do
      let(:school) { subject }

      before do
        school.name = 'Big School'
      end

      it 'is valid' do
        school.valid?
        expect(school.errors).not_to have_key(:name)
      end
    end

    context 'when a name is not supplied' do
      let(:school) { subject }

      before do
        school.name = nil
      end

      it 'is not valid' do
        school.valid?
        expect(school.errors).to have_key(:name)
        expect(school.errors[:name]).to include('Enter the name of the establishment')
      end
    end
  end

  describe '#preorder_status_or_default' do
    subject(:school) { build(:school) }

    context 'when the school has a preorder_information record with a status' do
      before do
        school.preorder_information = PreorderInformation.new(school: school, status: 'ready')
      end

      it 'returns the status from the preorder_information record' do
        expect(school.preorder_status_or_default).to eq('ready')
      end
    end

    context 'when the school has a preorder_information record without a status' do
      it 'infers the status' do
        school.build_preorder_information
        school.preorder_information.status = nil
        allow(school.preorder_information).to receive(:infer_status).and_return('inferred_status')

        expect(school.preorder_status_or_default).to eq('inferred_status')
      end
    end

    context 'when the school has no preorder status and the responsible_body is set to manage orders centrally' do
      before do
        school.preorder_information = nil
        school.responsible_body = build(:trust, who_will_order_devices: 'responsible_body')
      end

      it 'returns "needs_info"' do
        expect(school.preorder_status_or_default).to eq('needs_info')
      end
    end

    context 'when the school has no preorder status and the responsible_body is set to schools managing orders' do
      before do
        school.preorder_information = nil
        school.responsible_body = build(:trust, who_will_order_devices: 'school')
      end

      it 'returns "needs_contact"' do
        expect(school.preorder_status_or_default).to eq('needs_contact')
      end
    end
  end

  describe '#type_label' do
    subject { school.type_label }

    context 'for a special school' do
      let(:school) { build(:school, establishment_type: :special) }

      it { is_expected.to eq('Special school') }
    end

    context 'when the school is not a special school and the phase is primary' do
      let(:school) { build(:school, establishment_type: :academy, phase: :primary) }

      it { is_expected.to eq('Primary school') }
    end

    context 'when the school is not a special school and the phase is sixteen_plus' do
      let(:school) { build(:school, establishment_type: :local_authority, phase: :sixteen_plus) }

      it { is_expected.to eq('Sixteen plus school') }
    end

    context 'when the school is not a special school and the phase is not set' do
      let(:school) { build(:school, establishment_type: :academy, phase: :phase_not_applicable) }

      it { is_expected.to be_blank }
    end
  end

  describe '#has_std_device_allocation?' do
    let(:school) { create(:school) }

    context 'when there is no standard device allocation' do
      it 'is false' do
        expect(school.has_std_device_allocation?).to eq(false)
      end
    end

    context 'when there is a standard device allocation of the given type but the value is 0' do
      before do
        school.device_allocations << build(:school_device_allocation, device_type: 'std_device', allocation: 0)
      end

      it 'is false' do
        expect(school.has_std_device_allocation?).to eq(false)
      end
    end

    context 'when there is a standard device allocation' do
      before do
        school.device_allocations << build(:school_device_allocation, device_type: 'std_device', allocation: 1)
      end

      it 'is true' do
        expect(school.has_std_device_allocation?).to eq(true)
      end
    end

    context 'when there is a comms device allocation' do
      before do
        school.device_allocations << build(:school_device_allocation, device_type: 'coms_device', allocation: 1)
      end

      it 'is false' do
        expect(school.has_std_device_allocation?).to eq(false)
      end
    end
  end

  describe '#can_order_devices?' do
    let(:school) { create(:school, :in_lockdown) }

    context 'when there is no allocation of the given type' do
      it 'is false' do
        expect(school.can_order_devices?).to be false
      end
    end

    context 'when there is an allocation of the given type with cap = devices_ordered' do
      let(:cap) { 0 }
      let(:devices_ordered) { 0 }

      before do
        school.device_allocations << build(:school_device_allocation, device_type: 'std_device', cap: cap, devices_ordered: devices_ordered)
      end

      it 'is false' do
        expect(school.can_order_devices?).to eq(false)
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
        expect(school.can_order_devices?).to eq(true)
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
        expect(school.can_order_devices?).to eq(false)
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

      subject(:school) do
        create(:school, preorder_information: create(:preorder_information,
                                                     who_will_order_devices: :school))
      end

      before do
        school.preorder_information.update(school_contact: school_contact)
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
          .to change { school.preorder_information.status }.from('school_will_be_contacted').to('school_contacted')
      end
    end

    context 'when the school has no preorder information' do
      subject(:school) { build(:school, preorder_information: nil) }

      it 'does nothing' do
        expect { school.invite_school_contact }
          .not_to change { User.count }.from(0)
      end
    end

    context "when there isn't any contact specified yet" do
      subject(:school) do
        build(:school,
              preorder_information: build(:preorder_information, school_contact: nil))
      end

      it 'does nothing' do
        expect { school.invite_school_contact }
          .not_to change { User.count }.from(0)
      end
    end

    context 'when the school contact matches an existing user' do
      let(:school_contact) { build(:school_contact, email_address: 'jsmith@school.sch.gov.uk') }

      subject(:school) do
        build(:school,
              preorder_information: build(:preorder_information, school_contact: school_contact))
      end

      before do
        create(:user, email_address: 'jsmith@school.sch.gov.uk')
      end

      it 'does nothing' do
        expect { school.invite_school_contact }
          .not_to change { User.count }.from(1)
      end
    end
  end

  describe '#who_will_order_devices' do
    let(:local_authority) { build(:local_authority, who_will_order_devices: 'responsible_body') }

    subject(:school) { build(:school, :la_maintained, responsible_body: local_authority) }

    context 'when the school has a preorder_information' do
      before do
        school.preorder_information = build(:preorder_information, school: school, who_will_order_devices: 'school')
      end

      it 'returns the who_will_order_devices value from the preorder_information' do
        expect(school.who_will_order_devices).to eq('school')
      end
    end

    context 'when the school does not have a preorder_information' do
      before do
        school.preorder_information = nil
      end

      it 'returns the who_will_order_devices value from the responsible_body' do
        expect(school.who_will_order_devices).to eq('responsible_body')
      end
    end
  end

  describe '#active_responsible_users' do
    subject(:school) { create(:school, :la_maintained, :with_preorder_information, responsible_body: local_authority) }

    let!(:local_authority) { create(:local_authority) }
    let!(:school_user_who_has_signed_in) { create(:school_user, :signed_in_before, school: school) }
    let!(:responsible_body_user_who_has_signed_in) { create(:local_authority_user, :signed_in_before, responsible_body: local_authority) }

    context 'when the school will order their own devices' do
      before do
        school.preorder_information.who_will_order_devices = 'school'
        create(:school_user, :never_signed_in, school: school)
      end

      it 'returns the school users who have signed in' do
        expect(school.active_responsible_users).to eq([school_user_who_has_signed_in])
      end
    end

    context 'when the school will have device orders placed centrally' do
      before do
        school.preorder_information.who_will_order_devices = 'responsible_body'
        create(:local_authority_user, :never_signed_in, responsible_body: local_authority)
      end

      it 'returns the responsible_body users who have signed in' do
        expect(school.active_responsible_users).to eq([responsible_body_user_who_has_signed_in])
      end
    end
  end
end
