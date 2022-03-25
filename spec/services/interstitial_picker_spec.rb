require 'rails_helper'

RSpec.describe InterstitialPicker do
  describe '#call' do
    context 'rb user' do
      let(:user) { create :user, schools: [school], responsible_body: la }
      let(:service) { described_class.new(user: user) }
      let(:la) { school.responsible_body }
      let(:school) { create :iss_provision, :in_lockdown, laptops: [2, 1, 0] }

      it 'uses partial interstitials/responsible_body_user' do
        expect(service.call.partial).to eq 'interstitials/responsible_body_user'
      end
    end

    context 'school user' do
      let(:user) { create :user, schools: [iss_provision] }
      let(:service) { described_class.new(user: user) }
      let(:la) { school.responsible_body }
      let(:iss_provision) { create :iss_provision, :in_lockdown, laptops: [2, 1, 0] }

      it 'uses partial interstitials/school_user' do
        expect(service.call.partial).to eq 'interstitials/school_user'
      end
    end

    context 'no rb or school for user' do
      let(:user) { create :user }
      let(:service) { described_class.new(user: user) }

      it 'uses partial interstitials/default' do
        expect(service.call.partial).to eq 'interstitials/default'
      end
    end
  end
end
