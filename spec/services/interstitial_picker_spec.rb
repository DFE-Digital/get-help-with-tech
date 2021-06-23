require 'rails_helper'

RSpec.describe InterstitialPicker do
  describe '#call' do
    let(:service) { described_class.new(user: user) }

    context 'support user' do
      let(:user) { create :support_user }

      specify { expect(service.call.partial).to eq('interstitials/default') }
    end

    context 'mno user' do
      let(:user) { create :mno_user }

      specify { expect(service.call.partial).to eq('interstitials/default') }
    end

    context 'not support user' do
      let(:user) { create :school_user }

      specify { expect(service.call.partial).to eq('interstitials/school_user') }
    end
  end
end
