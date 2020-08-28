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

  describe 'email address should not be case-sensitive (bug 555)' do
    context 'a user with the same email as an existing user, but different case' do
      let(:new_user) { build(:local_authority_user, email_address: 'Email.Address@example.com') }
      let!(:lowercase_user) { create(:local_authority_user, email_address: new_user.email_address.downcase) }

      it 'should not be valid' do
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
end
