require 'rails_helper'

RSpec.describe InterstitialPicker do
  describe '#call' do
    context 'when LA user with LA funded provision' do
      let(:user) { create :user, schools: [school], responsible_body: la }
      let(:service) { described_class.new(user: user) }
      let(:la) { school.responsible_body }

      context 'when devices can be ordered' do
        let(:school) { create :iss_provision, :in_lockdown, laptops: [2, 1, 0] }

        it 'uses partial interstitials/la_funded_user' do
          expect(service.call.partial).to eq 'interstitials/la_funded_user'
        end
      end

      context 'when no devices can be ordered' do
        let(:school) { create :iss_provision, laptops: [1, 0, 0] }

        it 'uses partial interstitials/school_user' do
          expect(service.call.partial).to eq 'interstitials/school_user'
        end
      end
    end

    context 'when multiple LA funded provisions' do
      let(:user) { create :user, schools: [iss_provision, scl_provision] }
      let(:service) { described_class.new(user: user) }
      let(:la) { school.responsible_body }

      context 'when devices can be ordered' do
        let(:iss_provision) { create :iss_provision, :in_lockdown, laptops: [2, 1, 0] }
        let(:scl_provision) { create :scl_provision, :in_lockdown, laptops: [2, 1, 0] }

        it 'uses partial interstitials/la_funded_user' do
          expect(service.call.partial).to eq 'interstitials/la_funded_user'
        end
      end

      context 'when no devices can be ordered' do
        let(:iss_provision) { create :iss_provision, laptops: [1, 0, 0] }
        let(:scl_provision) { create :scl_provision, laptops: [1, 0, 0] }

        it 'uses partial interstitials/school_user' do
          expect(service.call.partial).to eq 'interstitials/school_user'
        end
      end
    end

    context 'when iss provision user' do
      let(:user) { create :user, schools: [school] }
      let(:service) { described_class.new(user: user) }

      context 'when devices can be orderd' do
        let(:school) { create :iss_provision, :in_lockdown, laptops: [2, 1, 0] }

        it 'uses partial interstitials/iss_provision_user' do
          expect(service.call.partial).to eq 'interstitials/iss_provision_user'
        end
      end

      context 'when no devices can be ordered' do
        let(:school) { create :iss_provision, laptops: [1, 0, 0] }

        it 'uses partial interstitials/school_user' do
          expect(service.call.partial).to eq 'interstitials/school_user'
        end
      end
    end

    context 'when scl provision user' do
      let(:user) { create :user, schools: [school] }
      let(:service) { described_class.new(user: user) }

      context 'when devices can be orderd' do
        let(:school) { create :scl_provision, :in_lockdown, laptops: [2, 1, 0] }

        it 'uses partial interstitials/scl_provision_user' do
          expect(service.call.partial).to eq 'interstitials/scl_provision_user'
        end
      end

      context 'when no devices can be ordered' do
        let(:school) { create :scl_provision, laptops: [1, 0, 0] }

        it 'uses partial interstitials/school_user' do
          expect(service.call.partial).to eq 'interstitials/school_user'
        end
      end
    end
  end
end
