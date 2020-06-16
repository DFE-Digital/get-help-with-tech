require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { subject }

  describe 'is_dfe?' do
    context 'when email address ends in education.gov.uk' do
      before do
        user.email_address = 'someone@education.gov.uk'
      end

      it 'is true' do
        expect(user.is_dfe?).to be(true)
      end
    end

    context 'when email address ends in digital.education.gov.uk' do
      before do
        user.email_address = 'someone@digital.education.gov.uk'
      end

      it 'is true' do
        expect(user.is_dfe?).to be(true)
      end
    end

    context 'when email address ends in education.gov' do
      before do
        user.email_address = 'someone@education.gov'
      end

      it 'is false' do
        expect(user.is_dfe?).to be(false)
      end
    end

    context 'when email address contains education.gov.uk but does not end with it' do
      before do
        user.email_address = 'phishing@education.gov.uk.spamdomain.com'
      end

      it 'is true' do
        expect(user.is_dfe?).to be(false)
      end
    end
  end

  describe 'is_mno_user?' do
    context 'when the user has a participating mobile_network' do
      let(:participating_mobile_network) { build(:mobile_network, participating_in_scheme: true) }

      before do
        user.mobile_network = participating_mobile_network
      end

      it 'is true' do
        expect(user.is_mno_user?).to be(true)
      end
    end

    context 'when the user has a non-participating mobile_network' do
      let(:participating_mobile_network) { build(:mobile_network, participating_in_scheme: false) }

      before do
        user.mobile_network = participating_mobile_network
      end

      it 'is true' do
        expect(user.is_mno_user?).to be(true)
      end
    end

    context 'when the user does not have a mobile_network' do
      before do
        user.mobile_network = nil
      end

      it 'is false' do
        expect(user.is_mno_user?).to be(false)
      end
    end
  end
end
