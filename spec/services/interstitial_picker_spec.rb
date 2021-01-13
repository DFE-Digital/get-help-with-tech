require 'rails_helper'

RSpec.describe InterstitialPicker do
  context 'with increased_sixth_form_feature_flag' do
    let(:allocation) { create(:school_device_allocation, :with_std_allocation, :with_available_devices) }
    let(:school) { create(:school, :in_lockdown, phase: 'sixteen_plus', device_allocations: [allocation], increased_sixth_form_feature_flag: true) }
    let(:school_user) { create(:school_user, school: school) }
    let(:rb) { create(:trust, schools: [school]) }
    let(:rb_user) { create(:trust_user, responsible_body: rb) }

    context 'when user has school that can order' do
      subject(:service) { described_class.new(user: school_user) }

      it 'shows increased allocation screen' do
        expect(service.call.partial).to eql('interstitials/increased_sixth_form_allocation')
      end
    end

    context 'when rb user has school that can order' do
      subject(:service) { described_class.new(user: rb_user) }

      it 'shows increased allocation screen' do
        expect(service.call.partial).to eql('interstitials/increased_sixth_form_allocation')
      end
    end
  end

  context 'with increased_fe_feature_flag' do
    let(:allocation) { create(:school_device_allocation, :with_std_allocation, :with_available_devices) }
    let(:school) { create(:school, :in_lockdown, phase: 'sixteen_plus', device_allocations: [allocation], increased_fe_feature_flag: true) }
    let(:school_user) { create(:school_user, school: school) }
    let(:rb) { create(:trust, schools: [school]) }
    let(:rb_user) { create(:trust_user, responsible_body: rb) }

    context 'when user has school that can order' do
      subject(:service) { described_class.new(user: school_user) }

      it 'shows increased allocation screen' do
        expect(service.call.partial).to eql('interstitials/increased_fe_allocation')
      end
    end

    context 'when rb user has school that can order' do
      subject(:service) { described_class.new(user: rb_user) }

      it 'shows increased allocation screen' do
        expect(service.call.partial).to eql('interstitials/increased_fe_allocation')
      end
    end
  end
end
