require 'rails_helper'

RSpec.describe User, type: :model do
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

  describe '#is_responsible_body_user?' do
    it 'is true when the user is from a trust' do
      user = build(:user, responsible_body: build(:trust))
      expect(user.is_responsible_body_user?).to be_truthy
    end

    it 'is true when the user is from a local authority' do
      user = build(:user, responsible_body: build(:local_authority))
      expect(user.is_responsible_body_user?).to be_truthy
    end

    it 'is false when the user is from an MNO' do
      user = build(:user, responsible_body: nil, mobile_network: build(:mobile_network))
      expect(user.is_responsible_body_user?).to be_falsey
    end

    it 'is false for DfE users' do
      user = build(:user, responsible_body: nil, email_address: 'ab@education.gov.uk')
      expect(user.is_responsible_body_user?).to be_falsey
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
        expect(user.errors.keys).to include(:orders_devices)
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

    context 'when the user is from a mobilenetwork' do
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

  describe 'paper_trail', versioning: true do
    context 'creating user' do
      context 'computacenter relevant' do
        it 'creates a Computacenter::UserChange of type new' do
          expect { create(:user, :has_seen_privacy_notice, orders_devices: true) }.to change(Computacenter::UserChange, :count).by(1)
        end

        it 'persists correct data for RB user' do
          user = create(:trust_user, orders_devices: true)
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
          expect(user_change.updated_at_timestamp).to eql(user.created_at)
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
          user = create(:school_user, orders_devices: true)
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
          expect(user_change.updated_at_timestamp).to eql(user.created_at)
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

      it 'persists correct data for hybrid user' do
        school = create(:school)
        responsible_body = create(:trust, schools: [school])
        create(:school_user,
               responsible_body: responsible_body,
               school: school,
               orders_devices: true)

        user_change = Computacenter::UserChange.last

        expect(user_change.responsible_body).to be_present
        expect(user_change.school).to be_blank
      end

      context 'not computacenter relevant' do
        it 'does not create a Computacenter::UserChange' do
          expect { create(:user, :has_not_seen_privacy_notice) }.not_to change(Computacenter::UserChange, :count)
        end
      end
    end

    context 'updating user' do
      context 'now computacenter relevant' do
        let!(:user) { create(:user, :not_relevant_to_computacenter) }

        def perform_change!
          user.update(privacy_notice_seen_at: 1.second.ago, orders_devices: true)
        end

        it 'creates a Computacenter::UserChange of type New' do
          expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)

          user_change = Computacenter::UserChange.last
          expect(user_change.type_of_update).to eql('New')
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
            user.school = other_school
            user.save!
          end

          it 'creates a Computacenter::UserChange' do
            expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)
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

          it 'stores correct original fields' do
            perform_change!
            user_change = Computacenter::UserChange.last

            expect(user_change.original_responsible_body).to be_nil
            expect(user_change.original_responsible_body_urn).to be_nil
            expect(user_change.original_cc_sold_to_number).to be_nil
          end

          it 'stores correct current fields' do
            perform_change!
            user_change = Computacenter::UserChange.last

            expect(user_change.responsible_body).to eql(responsible_body.name)
            expect(user_change.responsible_body_urn).to eql(responsible_body.computacenter_identifier)
            expect(user_change.cc_sold_to_number).to eql(responsible_body.computacenter_reference)
          end
        end

        context 'when school association is added' do
          let!(:school) { create(:school) }
          let!(:user) { create(:school_user, :relevant_to_computacenter, school: nil) }

          def perform_change!
            user.update(school: school)
          end

          it 'creates a Computacenter::UserChange' do
            expect { perform_change! }.to change(Computacenter::UserChange, :count).by(1)
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
          end
        end
      end

      context 'not computacenter relevant' do
        let!(:user) { create(:user, :not_relevant_to_computacenter) }

        it 'does not create a Computacenter::UserChange' do
          expect { user.update(email_address: 'change@example.com') }.not_to change(Computacenter::UserChange, :count)
        end
      end
    end

    context 'deleting user' do
      context 'computacenter relevant' do
        let!(:user) { create(:user, :relevant_to_computacenter) }
        let!(:original_user) { user }

        it 'creates a Computacenter::UserChange of type remove' do
          expect { user.destroy! }.to change(Computacenter::UserChange, :count).by(1)

          user_change = Computacenter::UserChange.last
          expect(user_change.type_of_update).to eql('Remove')
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
      end
    end
  end
end
