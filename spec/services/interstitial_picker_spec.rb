require 'rails_helper'

RSpec.describe InterstitialPicker do
  let(:allocation) { create(:school_device_allocation, :with_std_allocation, :with_available_devices) }
  let(:school) { create(:school, :in_lockdown, phase: 'sixteen_plus', device_allocations: [allocation]) }
  let(:school_user) { create(:school_user, school: school) }
  let(:rb) { create(:trust, schools: [school]) }
  let(:rb_user) { create(:trust_user, responsible_body: rb) }

  context 'when user has sixth form school that can order', with_feature_flags: { sixth_form_interstitial: 'active' } do
    subject(:service) { described_class.new(user: school_user) }

    it 'shows increased allocation screen' do
      expect(service.call.partial).to eql('interstitials/increased_sixth_form_allocation')
    end
  end

  context 'when rb user has sixth form school that can order', with_feature_flags: { sixth_form_interstitial: 'active' } do
    subject(:service) { described_class.new(user: rb_user) }

    it 'shows increased allocation screen' do
      expect(service.call.partial).to eql('interstitials/increased_sixth_form_allocation')
    end
  end
end
