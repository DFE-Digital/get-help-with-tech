require 'rails_helper'

RSpec.describe InterstitialPicker do
  describe '#call' do
    context 'when LA user + LA funded place user' do
      let(:school) { create :la_funded_place, std_device_allocation: allocation }
      let(:user) { create :user, schools: [school], responsible_body: la }
      let(:service) { described_class.new(user: user) }
      let(:la) { school.responsible_body }

      context 'when devices can be ordered' do
        let(:allocation) { create :school_device_allocation, :with_std_allocation, :with_orderable_devices }

        it 'uses partial interstitials/la_funded_user' do
          expect(service.call.partial).to eq 'interstitials/la_funded_rb_user'
        end
      end

      context 'when no devices can be ordered' do
        let(:allocation) { create :school_device_allocation, :with_std_allocation }

        it 'uses partial interstitials/school_user' do
          expect(service.call.partial).to eq 'interstitials/school_user'
        end
      end
    end

    context 'when LA funded place user' do
      let(:school) { create :la_funded_place, std_device_allocation: allocation }
      let(:user) { create :user, schools: [school] }
      let(:service) { described_class.new(user: user) }

      context 'when devices can be orderd' do
        let(:allocation) { create :school_device_allocation, :with_std_allocation, :with_orderable_devices }

        it 'uses partial interstitials/la_funded_user' do
          expect(service.call.partial).to eq 'interstitials/la_funded_user'
        end
      end

      context 'when no devices can be ordered' do
        let(:allocation) { create :school_device_allocation, :with_std_allocation }

        it 'uses partial interstitials/school_user' do
          expect(service.call.partial).to eq 'interstitials/school_user'
        end
      end
    end
  end
end
