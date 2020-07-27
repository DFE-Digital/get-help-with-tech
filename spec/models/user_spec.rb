require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#is_dfe?' do
    it 'is true when email address ends in education.gov.uk' do
      user = build(:user, email_address: 'someone@education.gov.uk')
      expect(user.is_dfe?).to be_truthy
    end

    it 'is true when email address ends in digital.education.gov.uk' do
      user = build(:user, email_address: 'someone@digital.education.gov.uk')
      expect(user.is_dfe?).to be_truthy
    end

    it 'is false when email address ends in education.gov' do
      user = build(:user, email_address: 'someone@education.gov')
      expect(user.is_dfe?).to be_falsey
    end

    it 'is false when email address contains education.gov.uk but does not end with it' do
      user = build(:user, email_address: 'phishing@education.gov.uk.spamdomain.com')
      expect(user.is_dfe?).to be_falsey
    end
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
end
