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

    context 'school user' do
      let(:school) { create(:school) }
      let(:user) { build(:school_user, :orders_devices, school: school) }

      before do
        create_list(:school_user, 3, :orders_devices, school: school)
      end

      it 'validates that only 3 users can order devices for a school' do
        expect(user.valid?).to be false
        expect(user.errors.keys).to include(:orders_devices)
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
  end
end
