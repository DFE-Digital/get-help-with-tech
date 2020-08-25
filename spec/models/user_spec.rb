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
end
