require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:email_audits).dependent(:destroy) }
  end

  describe '#is_mno_user?' do
    it 'is true when the user is from an MNO participating in the pilot' do
      user = build(:user, mobile_network: build(:mobile_network))
      expect(user.is_mno_user?).to be_truthy
    end

    it 'is true when the user is from an MNO not participating in the pilot' do
      user = build(:user, mobile_network: build(:mobile_network, :not_participating_in_pilot))
      expect(user.is_mno_user?).to be_truthy
    end

    it 'is false when the user is not associated with an MNO' do
      user = build(:user, mobile_network: nil)
      expect(user.is_mno_user?).to be_falsey
    end
  end

  describe '#responsible_body_user?' do
    it 'is true when the user is from a trust' do
      user = build(:user, responsible_body: build(:trust))
      expect(user.responsible_body_user?).to be_truthy
    end

    it 'is true when the user is from a local authority' do
      user = build(:user, responsible_body: build(:local_authority))
      expect(user.responsible_body_user?).to be_truthy
    end

    it 'is false when the user is from an MNO' do
      user = build(:user, responsible_body: nil, mobile_network: build(:mobile_network))
      expect(user.responsible_body_user?).to be_falsey
    end

    it 'is false for DfE users' do
      user = build(:user, responsible_body: nil, email_address: 'ab@education.gov.uk')
      expect(user.responsible_body_user?).to be_falsey
    end
  end

  describe '#is_school_user?' do
    it 'is true when the user is associated with a school' do
      user = build(:user, school: build(:school))
      expect(user.is_school_user?).to be_truthy
    end

    it 'is false when the user is not associated with a school' do
      user = build(:user, school: nil)
      expect(user.is_school_user?).to be_falsey
    end
  end

  describe 'single_school_user?' do
    context 'when the user has a responsible_body that is a single_academy_trust, but the user has no schools' do
      let(:user) { create(:single_academy_trust_user, schools: []) }

      it 'is false' do
        expect(user.single_school_user?).to be_falsey
      end
    end

    context 'when the user has a responsible_body and one school' do
      let(:school) { create(:school, :academy, responsible_body: responsible_body) }
      let(:user) { create(:trust_user, schools: [school], responsible_body: responsible_body, orders_devices: true) }

      context 'and the responsible_body is a single academy trust' do
        let(:responsible_body) { create(:trust, :single_academy_trust) }

        it 'is true' do
          expect(user.single_school_user?).to be_truthy
        end
      end

      context 'and the responsible_body is a FE academy college' do
        let(:responsible_body) { create(:further_education_college) }

        it 'is true' do
          expect(user.single_school_user?).to be_truthy
        end
      end

      context 'and the responsible_body is a multi academy trust' do
        let(:responsible_body) { create(:trust, :multi_academy_trust) }

        it 'is false' do
          expect(user.single_school_user?).to be_falsey
        end
      end

      context 'and the responsible_body is a local authority' do
        let(:responsible_body) { create(:local_authority) }

        it 'is false' do
          expect(user.single_school_user?).to be_falsey
        end
      end
    end
  end

  describe 'privacy notice' do
    it 'needs to be seen by responsible body users who havent seen it' do
      user = build(:local_authority_user, privacy_notice_seen_at: nil)
      expect(user.needs_to_see_privacy_notice?).to be_truthy
    end

    it 'does not need to be seen by responsible body users who have seen it' do
      user = build(:local_authority_user, :has_seen_privacy_notice)
      expect(user.needs_to_see_privacy_notice?).to be_falsey
    end

    it 'does not need to be seen by support users' do
      user = build(:dfe_user, privacy_notice_seen_at: nil)
      expect(user.needs_to_see_privacy_notice?).to be_falsey
    end

    it 'does not need to be seen by CC users' do
      user = build(:computacenter_user, privacy_notice_seen_at: nil)
      expect(user.needs_to_see_privacy_notice?).to be_falsey
    end
  end

  describe 'email address validation' do
    it { is_expected.not_to allow_value('invalid.email').for(:email_address) }
  end

  describe 'email address should not be case-sensitive (bug 555)' do
    context 'a user with the same email as an existing user, but different case' do
      let(:new_user) { build(:local_authority_user, email_address: 'Email.Address@example.com') }

      before do
        create(:local_authority_user, email_address: new_user.email_address.downcase)
      end

      it 'is not valid' do
        expect(new_user.valid?).to be_falsey
        expect(new_user.errors[:email_address]).not_to be_empty
      end
    end

    context 'creating a user with a mixed-case email address' do
      let(:new_user) { build(:local_authority_user, email_address: 'Mr.Mixed.Case@SOMEDOMAIN.org') }

      it 'forces the email_address to lower-case' do
        expect { new_user.save! }.to change(new_user, :email_address).to('mr.mixed.case@somedomain.org')
      end
    end
  end

  describe 'orders devices validation' do
    context 'for a school user' do
      let(:school) { create(:school) }
      let(:user) { build(:school_user, :orders_devices, school: school) }

      before do
        create_list(:school_user, 3, :orders_devices, school: school)
      end

      it 'validates that only 3 users can order devices for a school' do
        expect(user.valid?).to be false
        expect(user.errors.attribute_names).to include(:orders_devices)
      end

      it 'does not fail to update a user when there are 3 users that can order' do
        existing_user = school.users.last
        existing_user.sign_in_token = '1234'
        expect(existing_user.valid?).to be true
      end
    end
  end

  describe '#organisation_name' do
    let(:user) { build(:user) }

    context 'when the user is from a mobile network' do
      before { user.mobile_network = build(:mobile_network) }

      it 'returns the mobile networks brand' do
        expect(user.organisation_name).to eq(user.mobile_network.brand)
      end
    end

    context 'when the user is from a trust' do
      before { user.responsible_body = build(:trust) }

      it 'returns the trusts name' do
        expect(user.organisation_name).to eq(user.responsible_body.name)
      end
    end

    context 'when the user is from a local authority' do
      before { user.responsible_body = build(:local_authority) }

      it 'returns the local authoritys official name' do
        expect(user.organisation_name).to eq(user.responsible_body.local_authority_official_name)
      end
    end

    context 'when the user is from a school' do
      before { user.school = build(:school) }

      it 'returns the schools name' do
        expect(user.organisation_name).to eq(user.school.name)
      end
    end

    context 'when the user is from computacenter' do
      before { user.is_computacenter = true }

      it 'returns Computacenter' do
        expect(user.organisation_name).to eq('Computacenter')
      end
    end

    context 'when the user is a support user' do
      before { user.is_support = true }

      it 'returns DfE Support' do
        expect(user.organisation_name).to eq('DfE Support')
      end
    end
  end

  describe '#first_name' do
    context 'when full_name provided' do
      subject(:user) { described_class.new(full_name: 'John Doe') }

      it 'returns first_name' do
        expect(user.first_name).to eql('John')
      end
    end

    context 'when full_name is nil' do
      subject(:user) { described_class.new(full_name: nil) }

      it 'returns empty string' do
        expect(user.first_name).to eql('')
      end
    end

    context 'when full_name is empty string' do
      subject(:user) { described_class.new(full_name: '') }

      it 'returns empty string' do
        expect(user.first_name).to eql('')
      end
    end

    context 'when the full_name contains an honorific' do
      it 'returns the first name without the honorific' do
        expect(described_class.new(full_name: 'Mr John Smith').first_name).to eq('John')
        expect(described_class.new(full_name: 'Ms Jane Smith').first_name).to eq('Jane')
        expect(described_class.new(full_name: 'Miss Jane Smith').first_name).to eq('Jane')
        expect(described_class.new(full_name: 'Ms Jane Smith').first_name).to eq('Jane')
        expect(described_class.new(full_name: 'Dr Jane Smith').first_name).to eq('Jane')
      end
    end

    context 'when the full_name is a firstname.lastname@domain email address' do
      subject(:user) { described_class.new(full_name: 'jane.smith@school.sch.uk') }

      it 'guesses the first name from the local part' do
        expect(user.first_name).to eql('Jane')
      end
    end

    context 'when the full_name is a <initial>lastname@domain email address' do
      subject(:user) { described_class.new(full_name: 'jsmith@school.sch.uk') }

      it 'guesses the first name initial from the local part' do
        expect(user.first_name).to eql('J')
      end
    end
  end

  describe '#last_name' do
    context 'when full_name provided' do
      subject(:user) { described_class.new(full_name: 'John Doe') }

      it 'returns last_name' do
        expect(user.last_name).to eql('Doe')
      end
    end

    context 'when full_name is nil' do
      subject(:user) { described_class.new(full_name: nil) }

      it 'returns empty string' do
        expect(user.last_name).to eql('')
      end
    end

    context 'when full_name is empty string' do
      subject(:user) { described_class.new(full_name: '') }

      it 'returns empty string' do
        expect(user.last_name).to eql('')
      end
    end

    context 'when the full_name contains an honorific' do
      it 'returns the last name without the honorific' do
        expect(described_class.new(full_name: 'Mr John Smith').last_name).to eq('Smith')
        expect(described_class.new(full_name: 'Ms Jane Smith').last_name).to eq('Smith')
        expect(described_class.new(full_name: 'Miss Jane Smith').last_name).to eq('Smith')
        expect(described_class.new(full_name: 'Ms Jane Smith').last_name).to eq('Smith')
        expect(described_class.new(full_name: 'Dr Jane Smith').last_name).to eq('Smith')
      end
    end

    context 'when the full_name is a firstname.lastname@domain email address' do
      subject(:user) { described_class.new(full_name: 'jane.smith@school.sch.uk') }

      it 'guesses the last name from the local part' do
        expect(user.last_name).to eql('Smith')
      end
    end

    context 'when the full_name is a <initial>lastname@domain email address' do
      subject(:user) { described_class.new(full_name: 'jsmith@school.sch.uk') }

      it 'guesses the first name initial from the local part' do
        expect(user.last_name).to eql('Smith')
      end
    end
  end

  describe 'generating user changes for downstream Computacenter systems' do
    before do
      allow(Settings.computacenter.service_now_user_import_api).to receive(:endpoint).and_return('http://example.com/import/table')
      ActiveJob::Base.queue_adapter = :test
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    end

    context 'creating user' do
      context 'computacenter relevant' do
        let(:expected_time) { 2.seconds.ago }

        it 'creates a Computacenter::UserChange of type new' do
          expect { create(:user, :relevant_to_computacenter) }.to change(Computacenter::UserChange, :count).by(1)
        end

        it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
          user = create(:user, :has_seen_privacy_notice, orders_devices: true)
          expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
        end

        it 'persists correct data for RB user' do
          Timecop.travel(expected_time)
          user = create(:trust_user, orders_devices: true)
          Timecop.return
          user_change = Computacenter::UserChange.last

          expect(user_change.user_id).to eql(user.id)
          expect(user_change.first_name).to eql(user.first_name)
          expect(user_change.last_name).to eql(user.last_name)
          expect(user_change.email_address).to eql(user.email_address)
          expect(user_change.telephone).to eql(user.telephone)
          expect(user_change.responsible_body).to eql(user.effective_responsible_body.name)
          expect(user_change.responsible_body_urn).to eql(user.effective_responsible_body.computacenter_identifier)
          expect(user_change.cc_sold_to_number).to eql(user.effective_responsible_body.computacenter_reference)
          expect(user_change.school).to be_blank
          expect(user_change.school_urn).to be_blank
          expect(user_change.cc_ship_to_number).to be_blank
          expect(user_change.updated_at_timestamp).to be_within(1.second).of(expected_time)
          expect(user_change.type_of_update).to eql('New')
          expect(user_change.original_email_address).to be_nil
          expect(user_change.original_first_name).to be_blank
          expect(user_change.original_last_name).to be_blank
          expect(user_change.original_telephone).to be_nil
          expect(user_change.original_responsible_body).to be_nil
          expect(user_change.original_responsible_body_urn).to be_nil
          expect(user_change.original_cc_sold_to_number).to be_nil
          expect(user_change.original_school).to be_blank
          expect(user_change.original_school_urn).to be_blank
          expect(user_change.original_cc_ship_to_number).to be_blank
        end

        it 'persists correct data for school user' do
          Timecop.travel(expected_time)
          user = create(:school_user, orders_devices: true)
          Timecop.return

          user_change = Computacenter::UserChange.last

          expect(user_change.user_id).to eql(user.id)
          expect(user_change.first_name).to eql(user.first_name)
          expect(user_change.last_name).to eql(user.last_name)
          expect(user_change.email_address).to eql(user.email_address)
          expect(user_change.telephone).to eql(user.telephone)
          expect(user_change.responsible_body).to eql(user.effective_responsible_body.name)
          expect(user_change.responsible_body_urn).to eql(user.effective_responsible_body.computacenter_identifier)
          expect(user_change.cc_sold_to_number).to eql(user.effective_responsible_body.computacenter_reference)
          expect(user_change.school).to eql(user.school.name)
          expect(user_change.school_urn).to eql(user.school.urn.to_s)
          expect(user_change.cc_ship_to_number).to eql(user.school.computacenter_reference)
          expect(user_change.updated_at_timestamp).to be_within(1.second).of(expected_time)
          expect(user_change.type_of_update).to eql('New')
          expect(user_change.original_email_address).to be_nil
          expect(user_change.original_first_name).to be_blank
          expect(user_change.original_last_name).to be_blank
          expect(user_change.original_telephone).to be_nil
          expect(user_change.original_responsible_body).to be_nil
          expect(user_change.original_responsible_body_urn).to be_nil
          expect(user_change.original_cc_sold_to_number).to be_nil
          expect(user_change.original_school).to be_blank
          expect(user_change.original_school_urn).to be_blank
          expect(user_change.original_cc_ship_to_number).to be_blank
        end
      end

      context 'when the user has a school and is relevant_to_computacenter' do
        before do
          Computacenter::UserChange.delete_all
          create(:school_user, :relevant_to_computacenter, email_address: 'old@example.com')
        end

        it 'does not create any UserChanges without a user_id (bug found & fixed in PR #634)' do
          expect(Computacenter::UserChange.where(user_id: nil).count).to eq(0)
        end

        context 'when the school has a computacenter_reference' do
          let(:school) { create(:school, computacenter_reference: '123456') }
          let!(:user) { create(:school_user, :relevant_to_computacenter, email_address: 'user@example.com', schools: [school]) }

          it 'creates a UserChange' do
            expect(Computacenter::UserChange.latest_for_user(user)).not_to be_nil
          end
        end

        context 'when the school does not have a computacenter_reference' do
          let(:school) { create(:school, computacenter_reference: '') }
          let!(:user) { create(:school_user, :relevant_to_computacenter, email_address: 'user@example.com', schools: [school]) }

          it 'does not create a UserChange' do
            expect(Computacenter::UserChange.latest_for_user(user)).to be_nil
          end
        end
      end

      it 'persists correct data for single academy trust user' do
        school = create(:school)
        responsible_body = create(:trust, :single_academy_trust, schools: [school])
        create(:school_user,
               responsible_body: responsible_body,
               school: school,
               orders_devices: true)

        user_change = Computacenter::UserChange.last

        expect(user_change.responsible_body).to be_present
        expect(user_change.school).to be_blank
      end

      context 'when an FE school user' do
        it 'persists correct data' do
          school = create(:fe_school)
          user = create(:user, school: school, orders_devices: true)
          user_change = Computacenter::UserChange.last

          expect(user_change.user_id).to eql(user.id)
          expect(user_change.first_name).to eql(user.first_name)
          expect(user_change.last_name).to eql(user.last_name)
          expect(user_change.email_address).to eql(user.email_address)
          expect(user_change.telephone).to eql(user.telephone)
          expect(user_change.responsible_body).to eql(school.responsible_body.name)
          expect(user_change.responsible_body_urn.to_s).to eql(school.responsible_body.computacenter_identifier.to_s)
          expect(user_change.cc_sold_to_number).to eql(school.responsible_body.computacenter_reference)
          expect(user_change.school).to eql(user.school.name)
          expect(user_change.school_urn).to eql(user.school.ukprn.to_s)
          expect(user_change.cc_ship_to_number).to eql(user.school.computacenter_reference)
          expect(user_change.updated_at_timestamp).to be_within(10.seconds).of(user.created_at)
          expect(user_change.type_of_update).to eql('New')
          expect(user_change.original_email_address).to be_nil
          expect(user_change.original_first_name).to be_nil
          expect(user_change.original_last_name).to be_nil
          expect(user_change.original_telephone).to be_nil
          expect(user_change.original_responsible_body).to be_nil
          expect(user_change.original_responsible_body_urn).to be_nil
          expect(user_change.original_cc_sold_to_number).to be_nil
          expect(user_change.original_school).to be_blank
          expect(user_change.original_school_urn).to be_blank
          expect(user_change.original_cc_ship_to_number).to be_blank
        end
      end

      context 'not computacenter relevant' do
        it 'does not create a Computacenter::UserChange' do
          expect { create(:user, :has_not_seen_privacy_notice) }.not_to change(Computacenter::UserChange, :count)
        end

        it 'does not schedule a NotifyComputacenterOfLatestChangeForUserJob for the user' do
          create(:user, :has_not_seen_privacy_notice)
          expect(NotifyComputacenterOfLatestChangeForUserJob).not_to have_been_enqueued
        end
      end
    end

    context 'updating user' do
      context 'now computacenter relevant' do
        let!(:user) { create(:user, :not_relevant_to_computacenter) }

        before do
          ActiveJob::Base.queue_adapter.enqueued_jobs.clear
        end

        def perform_change!
          user.update(privacy_notice_seen_at: 1.second.ago, orders_devices: true)
        end

        it 'creates a Computacenter::UserChange of type New' do
          expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)

          user_change = Computacenter::UserChange.last
          expect(user_change.type_of_update).to eql('New')
        end

        it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
          perform_change!
          expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
        end

        it 'sets current fields' do
          perform_change!

          user_change = Computacenter::UserChange.last
          expect(user_change.email_address).to eql(user.email_address)
        end

        it 'does not set original fields' do
          perform_change!

          user_change = Computacenter::UserChange.last
          expect(user_change.original_email_address).to be_nil
        end
      end

      context 'already computacenter relevant' do
        let!(:user) { create(:trust_user, :relevant_to_computacenter, full_name: 'Jane Smith') }

        before do
          ActiveJob::Base.queue_adapter.enqueued_jobs.clear
        end

        context 'single field is changed' do
          let!(:original_email) { user.email_address }
          let!(:original_full_name) { user.full_name }
          let!(:original_telephone) { user.telephone }

          def perform_change!
            user.update(email_address: 'change@example.com',
                        full_name: 'John Doe',
                        telephone: '02012345678')
          end

          it 'creates a Computacenter::UserChange of type Change' do
            expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)

            user_change = Computacenter::UserChange.last
            expect(user_change.type_of_update).to eql('Change')
          end

          it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
            perform_change!
            expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
          end

          it 'sets current fields' do
            perform_change!

            user_change = Computacenter::UserChange.last
            expect(user_change.email_address).to eql('change@example.com')
            expect(user_change.first_name).to eql('John')
            expect(user_change.last_name).to eql('Doe')
            expect(user_change.telephone).to eql('02012345678')
          end

          it 'sets original fields' do
            perform_change!

            user_change = Computacenter::UserChange.last
            expect(user_change.original_email_address).to eql(original_email)
            expect(user_change.original_first_name).to eql(original_full_name.split(' ').first)
            expect(user_change.original_last_name).to eql(original_full_name.split(' ').last)
            expect(user_change.original_telephone).to eql(original_telephone)
          end
        end

        context 'when orders_devices is updated from true to false' do
          let(:perform_change!) do
            user.update(orders_devices: false)
          end

          it 'creates a Computacenter::UserChange of type Remove' do
            expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)

            user_change = Computacenter::UserChange.last
            expect(user_change.type_of_update).to eql('Remove')
          end

          it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
            perform_change!
            expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
          end

          it 'sets all current fields' do
            perform_change!

            user_change = Computacenter::UserChange.last
            expect(user_change.email_address).to eql(user.email_address)
          end

          it 'sets all original fields' do
            perform_change!

            user_change = Computacenter::UserChange.last
            expect(user_change.original_email_address).to eql(user.email_address)
          end
        end

        context 'when none computacenter significant field updated' do
          def perform_change!
            user.update(sign_in_token: 'abc')
          end

          it 'does not create a Computacenter::UserChange' do
            expect { perform_change! }.not_to change(Computacenter::UserChange, :count)
          end

          it 'does not schedule a NotifyComputacenterOfLatestChangeForUserJob for the user' do
            perform_change!
            expect(NotifyComputacenterOfLatestChangeForUserJob).not_to have_been_enqueued
          end
        end

        context 'when RB association is changed' do
          let!(:other_responsible_body) { create(:local_authority) }
          let!(:original_responsible_body) { user.responsible_body }
          let!(:user) { create(:trust_user, :relevant_to_computacenter) }

          def perform_change!
            user.update(responsible_body: other_responsible_body)
          end

          it 'creates a Computacenter::UserChange' do
            expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)
          end

          it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
            perform_change!
            expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
          end

          it 'stores correct original fields' do
            perform_change!
            user_change = Computacenter::UserChange.last

            expect(user_change.original_responsible_body).to eql(original_responsible_body.name)
            expect(user_change.original_responsible_body_urn).to eql(original_responsible_body.computacenter_identifier)
            expect(user_change.original_cc_sold_to_number).to eql(original_responsible_body.computacenter_reference)
          end

          it 'stores correct current fields' do
            perform_change!
            user_change = Computacenter::UserChange.last

            expect(user_change.responsible_body).to eql(other_responsible_body.name)
            expect(user_change.responsible_body_urn).to eql(other_responsible_body.computacenter_identifier)
            expect(user_change.cc_sold_to_number).to eql(other_responsible_body.computacenter_reference)
          end
        end

        context 'when school association is changed' do
          let!(:original_school) { create(:school) }
          let!(:other_school) { create(:school) }
          let!(:user) { create(:school_user, :relevant_to_computacenter, school: original_school) }

          def perform_change!
            user.update!(school: other_school)
          end

          it 'creates a Computacenter::UserChange' do
            expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)
          end

          it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
            perform_change!
            expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
          end

          it 'stores correct original fields' do
            perform_change!
            user_change = Computacenter::UserChange.last

            expect(user_change.original_school).to eql(original_school.name)
            expect(user_change.original_school_urn).to eql(original_school.urn.to_s)
            expect(user_change.original_cc_ship_to_number).to eql(original_school.computacenter_reference)
          end

          it 'stores correct current fields' do
            perform_change!
            user_change = Computacenter::UserChange.last

            expect(user_change.school).to eql(other_school.name)
            expect(user_change.school_urn).to eql(other_school.urn.to_s)
            expect(user_change.cc_ship_to_number).to eql(other_school.computacenter_reference)
          end
        end

        context 'when RB association is added' do
          let!(:responsible_body) { create(:local_authority) }
          let!(:user) { create(:trust_user, :relevant_to_computacenter, responsible_body: nil) }

          def perform_change!
            user.update(responsible_body: responsible_body)
          end

          it 'creates a Computacenter::UserChange' do
            expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)
          end

          it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
            perform_change!
            expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
          end

          it 'stores correct original fields' do
            perform_change!
            user_change = Computacenter::UserChange.last

            expect(user_change.original_responsible_body).to be_blank
            expect(user_change.original_responsible_body_urn).to be_blank
            expect(user_change.original_cc_sold_to_number).to be_blank
          end

          it 'stores correct current fields' do
            perform_change!
            user_change = Computacenter::UserChange.last

            expect(user_change.responsible_body).to eql(responsible_body.name)
            expect(user_change.responsible_body_urn).to eql(responsible_body.computacenter_identifier)
            expect(user_change.cc_sold_to_number).to eql(responsible_body.computacenter_reference)
          end
        end

        context 'when school association is updated from nil' do
          let!(:school) { create(:school) }
          let!(:user) { create(:user, :relevant_to_computacenter, school: nil) }

          def perform_change!
            user.update!(school: school)
          end

          it 'creates a Computacenter::UserChange' do
            expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)
          end

          it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
            perform_change!
            expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
          end

          it 'stores correct original fields' do
            perform_change!
            user_change = Computacenter::UserChange.last
            expect(user_change.original_school).to be_blank
            expect(user_change.original_school_urn).to be_blank
            expect(user_change.original_cc_ship_to_number).to be_blank
          end

          it 'stores correct current fields' do
            perform_change!
            user_change = Computacenter::UserChange.last

            expect(user_change.school).to eql(school.name)
            expect(user_change.school_urn).to eql(school.urn.to_s)
            expect(user_change.cc_ship_to_number).to eql(school.computacenter_reference)
            expect(user_change.responsible_body).to eql(school.responsible_body.name)
          end
        end

        context 'when a school is added to a user who already has a responsible_body different to that of the school' do
          let!(:rb) { create(:trust) }
          let!(:other_rb) { create(:trust) }
          let(:user_change) { Computacenter::UserChange.last }
          let(:perform_change!) { user.update!(school: school) }
          let!(:school) { create(:school, responsible_body: rb) }
          let!(:user) { create(:trust_user, :relevant_to_computacenter, school: nil, responsible_body: other_rb) }

          before do
            user.update!(responsible_body: other_rb)
            perform_change!
          end

          it 'shows both RBs in the RB field' do
            expect(user_change.responsible_body).to eql([other_rb.name, school.responsible_body.name].join('|'))
          end

          it 'shows both RB computacenter_identifiers in the RB URN field' do
            expect(user_change.responsible_body_urn).to eql([other_rb.computacenter_identifier, school.responsible_body.computacenter_identifier].join('|'))
          end

          it 'shows both RB computacenter_references in the cc_sold_to_number field' do
            expect(user_change.cc_sold_to_number).to eql([other_rb.computacenter_reference, school.responsible_body.computacenter_reference].join('|'))
          end
        end
      end

      context 'when a user has a second school association added' do
        let!(:school) { create(:school) }
        let!(:other_school) { create(:school) }
        let!(:user) { create(:school_user, :relevant_to_computacenter, school: school) }

        before do
          ActiveJob::Base.queue_adapter.enqueued_jobs.clear
        end

        def perform_change!
          user.schools << other_school
        end

        it 'creates a Computacenter::UserChange' do
          expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)
        end

        it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
          perform_change!
          expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
        end

        it 'stores correct original fields' do
          perform_change!
          user_change = Computacenter::UserChange.last
          expect(user_change.original_school).to eq(school.name)
          expect(user_change.original_school_urn).to eq(school.urn.to_s)
          expect(user_change.original_cc_ship_to_number).to eq(school.computacenter_reference)
        end

        it 'stores the school fields as pipe-delimited lists' do
          perform_change!
          user_change = Computacenter::UserChange.last

          expect(user_change.school).to eql("#{school.name}|#{other_school.name}")
          expect(user_change.school_urn).to eql("#{school.urn}|#{other_school.urn}")
          expect(user_change.cc_ship_to_number).to eql("#{school.computacenter_reference}|#{other_school.computacenter_reference}")
        end

        context "when the user's schools each have a different responsible body" do
          let(:other_responsible_body) { create(:trust) }
          let(:user_change) { Computacenter::UserChange.last }

          before do
            other_school.update!(responsible_body: other_responsible_body)
            perform_change!
          end

          it 'shows both schools RBs in the RB field' do
            expect(user_change.responsible_body).to eql([school.responsible_body.name, other_school.responsible_body.name].join('|'))
          end

          it 'shows both schools RB computacenter_identifiers in the RB URN field' do
            expect(user_change.responsible_body_urn).to eql([school.responsible_body.computacenter_identifier, other_school.responsible_body.computacenter_identifier].join('|'))
          end

          it 'shows both schools RB computacenter_references in the cc_sold_to_number field' do
            expect(user_change.cc_sold_to_number).to eql([school.responsible_body.computacenter_reference, other_school.responsible_body.computacenter_reference].join('|'))
          end
        end
      end

      context 'not computacenter relevant' do
        let!(:user) { create(:user, :not_relevant_to_computacenter) }
        let(:perform_change!) { user.update(email_address: 'change@example.com') }

        before do
          ActiveJob::Base.queue_adapter.enqueued_jobs.clear
        end

        it 'does not create a Computacenter::UserChange' do
          expect { perform_change! }.not_to change(Computacenter::UserChange, :count)
        end

        it 'does not schedule a NotifyComputacenterOfLatestChangeForUserJob for the user' do
          perform_change!
          expect(NotifyComputacenterOfLatestChangeForUserJob).not_to have_been_enqueued
        end
      end

      context 'BUG #815 - when the user already has a UserChange of type Remove' do
        let!(:user) { create(:user, :relevant_to_computacenter) }

        before do
          # this will generate a UserChange of type Remove
          user.update!(orders_devices: false)
          ActiveJob::Base.queue_adapter.enqueued_jobs.clear
        end

        context 'when the user is updated' do
          let(:perform_change!) do
            user.update!(full_name: Faker::Name.unique.name)
          end

          it 'does not create a Computacenter::UserChange' do
            expect { perform_change! }.not_to change(Computacenter::UserChange, :count)
          end

          it 'does not schedule a NotifyComputacenterOfLatestChangeForUserJob for the user' do
            perform_change!
            expect(NotifyComputacenterOfLatestChangeForUserJob).not_to have_been_enqueued
          end
        end

        context 'when the user is reactivated (BUG #881)' do
          let(:perform_change!) do
            user.update!(orders_devices: true)
          end

          it 'generates a Computacenter::UserChange of type New' do
            expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)

            user_change = Computacenter::UserChange.last
            expect(user_change.type_of_update).to eql('New')
          end

          it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
            perform_change!
            expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
          end
        end
      end
    end

    context 'deleting user' do
      context 'computacenter relevant' do
        let!(:user) { create(:user, :relevant_to_computacenter) }
        let!(:original_user) { user }

        before do
          ActiveJob::Base.queue_adapter.enqueued_jobs.clear
        end

        it 'creates a Computacenter::UserChange of type remove' do
          expect { user.destroy! }.to change(Computacenter::UserChange, :count).by(1)

          user_change = Computacenter::UserChange.last
          expect(user_change.type_of_update).to eql('Remove')
        end

        it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
          user.destroy!
          expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
        end

        it 'sets all original fields' do
          user.destroy!

          user_change = Computacenter::UserChange.last
          expect(user_change.original_email_address).to eql(original_user.email_address)
        end
      end

      context 'not computacenter relevant' do
        let!(:user) { create(:user, :not_relevant_to_computacenter) }

        it 'does not create a Computacenter::UserChange' do
          expect { user.destroy! }.not_to change(Computacenter::UserChange, :count)
        end

        it 'does not schedule a NotifyComputacenterOfLatestChangeForUserJob for the user' do
          user.destroy!
          expect(NotifyComputacenterOfLatestChangeForUserJob).not_to have_been_enqueued
        end
      end

      context 'user is a rb key contact' do
        let(:user) { create(:user) }
        let!(:rb) { create(:trust, key_contact: user) }

        it 'nullifies the rb key contact' do
          user.destroy!
          expect(rb.reload.key_contact_id).to be_nil
        end
      end

      context 'user is created_by for an extra mobile data request' do
        let(:rb) { create(:trust) }
        let(:user) { create(:user) }
        let!(:extra_mobile_data_request) { create(:extra_mobile_data_request, created_by_user: user, responsible_body: rb) }

        it 'nullifies the extra mobile data request created by user' do
          user.destroy!
          expect(extra_mobile_data_request.reload.created_by_user_id).to be_nil
        end
      end
    end

    describe 'marking user as soft deleted' do
      context 'computacenter relevant' do
        let!(:user) { create(:user, :relevant_to_computacenter) }
        let!(:original_user) { user }

        before do
          ActiveJob::Base.queue_adapter.enqueued_jobs.clear
        end

        it 'creates a Computacenter::UserChange of type remove' do
          expect { user.update!(deleted_at: 1.second.ago) }.to change(Computacenter::UserChange, :count).by(1)

          user_change = Computacenter::UserChange.last
          expect(user_change.type_of_update).to eql('Remove')
        end

        it 'schedules a NotifyComputacenterOfLatestChangeForUserJob for the user' do
          user.update!(deleted_at: 1.second.ago)
          expect(NotifyComputacenterOfLatestChangeForUserJob).to have_been_enqueued.with(user.id)
        end

        it 'sets all original fields' do
          user.update!(deleted_at: 1.second.ago)

          user_change = Computacenter::UserChange.last
          expect(user_change.original_email_address).to eql(original_user.email_address)
        end
      end

      context 'not computacenter relevant' do
        let!(:user) { create(:user, :not_relevant_to_computacenter) }

        it 'does not create a Computacenter::UserChange' do
          expect { user.update!(deleted_at: 1.second.ago) }.not_to change(Computacenter::UserChange, :count)
        end

        it 'does not schedule a NotifyComputacenterOfLatestChangeForUserJob for the user' do
          user.update!(deleted_at: 1.second.ago)
          expect(NotifyComputacenterOfLatestChangeForUserJob).not_to have_been_enqueued
        end
      end
    end
  end

  describe '#awaiting_techsource_account?' do
    context 'user orders devices and techsource account not confirmed' do
      subject(:user) do
        described_class.new(
          orders_devices: true,
          techsource_account_confirmed_at: nil,
        )
      end

      it 'returns true' do
        expect(user.awaiting_techsource_account?).to be_truthy
      end
    end

    context 'user orders devices and techsource account confirmed' do
      subject(:user) do
        described_class.new(
          orders_devices: true,
          techsource_account_confirmed_at: 1.second.ago,
        )
      end

      it 'returns false' do
        expect(user.awaiting_techsource_account?).to be_falsey
      end
    end

    context 'user does not order devices' do
      subject(:user) do
        described_class.new(
          orders_devices: false,
        )
      end

      it 'returns false' do
        expect(user.awaiting_techsource_account?).to be_falsey
      end
    end
  end

  describe 'removing the user from a school' do
    context 'when there is a SchoolWelcomeWizard for that user and school' do
      let(:user) { create(:school_user, :has_partially_completed_wizard) }

      context 'by destroying the user_school object' do
        let(:change!) { user.user_schools.first.destroy! }

        it 'deletes the wizard' do
          expect { change! }.to change(user.school_welcome_wizards.reload, :count).by(-1)
        end
      end

      context 'by updating the schools association' do
        let(:change!) { user.update!(schools: []) }

        it 'deletes the wizard' do
          expect { change! }.to change(user.school_welcome_wizards.reload, :count).by(-1)
        end
      end
    end
  end

  describe '#schools_i_order_for' do
    context 'when they dont order devices' do
      subject(:user) { create(:user, orders_devices: false) }

      it 'returns []' do
        expect(user.schools_i_order_for).to be_empty
      end
    end

    context 'when they order devices' do
      let(:rb) { create(:trust) }

      let(:included_school) { create(:school, preorder_information: create(:preorder_information, who_will_order_devices: 'school')) }
      let(:excluded_school) { create(:school, preorder_information: create(:preorder_information, who_will_order_devices: 'responsible_body')) }

      let(:included_rb_school) { create(:school, preorder_information: create(:preorder_information, who_will_order_devices: 'responsible_body')) }
      let(:excluded_rb_school) { create(:school, preorder_information: create(:preorder_information, who_will_order_devices: 'school')) }

      subject(:user) { create(:user, orders_devices: true, responsible_body: rb) }

      before do
        user.schools << included_school
        user.schools << excluded_school
        rb.schools << included_rb_school
        rb.schools << excluded_rb_school
      end

      it 'includes schools who will order their own devices' do
        expect(user.schools_i_order_for).to include(included_school)
        expect(user.schools_i_order_for).not_to include(excluded_school)
      end

      it 'includes responsible body schools where responsible body orders' do
        expect(user.schools_i_order_for).to include(included_rb_school)
        expect(user.schools_i_order_for).not_to include(excluded_rb_school)
      end
    end
  end

  describe '#organisations' do
    it 'includes the schools and responsible body that the user belongs to' do
      user = create(:local_authority_user, schools: create_list(:school, 2))

      expect(user.organisations.size).to eq(3)
      expect(user.organisations).to include(user.responsible_body)
      expect(user.organisations).to include(*user.schools)
    end
  end

  describe '.search_by_email_address_or_full_name' do
    def user_search(search_string)
      User.search_by_email_address_or_full_name(search_string)
    end

    it 'filters case insensitively on parts of the email address' do
      user = create(:school_user, email_address: 'admin@school.sch.uk')
      expect(user_search('Admin')).to eq([user])
      expect(user_search('xxx')).to be_empty
    end

    it 'filters case insensitively on parts of the name' do
      user = create(:school_user, full_name: 'Jane Smith')
      expect(user_search('jane')).to eq([user])
      expect(user_search('smith')).to eq([user])
      expect(user_search('bob')).to be_empty
    end

    it 'ignores whitespace padding' do
      user = create(:school_user, email_address: 'user@example.com', full_name: 'John Doe')
      expect(user_search('  user@example.com  ')).to eq([user])
      expect(user_search('user@example.com  ')).to eq([user])
      expect(user_search('  user@example.com')).to eq([user])

      expect(user_search('  John Doe  ')).to eq([user])
      expect(user_search('  Doe  ')).to eq([user])
    end
  end

  describe '.from_responsible_body_or_schools' do
    it 'filters school users' do
      user = create(:school_user)
      expect(User.from_responsible_body_or_schools).to eq([user])
    end

    it 'filters responsible body users' do
      user = create(:local_authority_user)
      expect(User.from_responsible_body_or_schools).to eq([user])
    end

    it 'ignores MNO, CC and support users' do
      create(:computacenter_user, full_name: 'Jane Smith 1')
      create(:mno_user, full_name: 'Jane Smith 2')
      create(:support_user, full_name: 'Jane Smith 3')
      expect(User.from_responsible_body_or_schools).to be_empty
    end
  end

  describe '#privileges' do
    subject(:model) do
      User.new(
        is_support: true,
        role: 'third_line',
        is_computacenter: true,
        mobile_network: build(:mobile_network),
      )
    end

    it 'returns correct privileges' do
      expect(model.privileges).to include(:support_user)
      expect(model.privileges).to include(:third_line_support_user)
      expect(model.privileges).to include(:computacenter_user)
      expect(model.privileges).to include(:mno_user)
    end
  end
end
