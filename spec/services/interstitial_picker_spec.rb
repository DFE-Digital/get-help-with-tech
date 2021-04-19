require 'rails_helper'

RSpec.describe InterstitialPicker do
  describe 'calling interstitial picker for LA user + LA funded place user' do
    let(:school) { create :la_funded_place }
    let(:user) { create :user, schools: [school], responsible_body: la }
    let(:service) { described_class.new(user: user) }
    let(:la) { school.responsible_body }

    context 'when an interstitial picker' do
      it 'route to interstitials/la_funded_user' do
        expect(service.call.partial).to eq 'interstitials/la_funded_rb_user'
      end
    end
  end

  describe 'calling interstitial picker for la funded place' do
    let(:school) { create :la_funded_place }
    let(:user) { create :user, schools: [school] }
    let(:service) { described_class.new(user: user) }

    context 'when an interstitial picker' do
      it 'route to interstitials/la_funded_user' do
        expect(service.call.partial).to eq 'interstitials/la_funded_user'
      end
    end
  end
end
