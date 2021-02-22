require 'rails_helper'

describe ExtraMobileDataRequestPolicy do
  subject(:policy) { described_class }

  let(:object) { build(:extra_mobile_data_request) }

  permissions :new?, :create?, :edit?, :update?, :destroy? do
    it 'blocks access to support users' do
      expect(policy).not_to permit(build(:support_user), object)
    end

    it 'blocks access to Computacenter users' do
      expect(policy).not_to permit(build(:computacenter_user), object)
    end
  end

  permissions :index?, :show? do
    it 'grants access to support users' do
      expect(policy).to permit(build(:support_user), object)
    end

    it 'blocks access to Computacenter users' do
      expect(policy).not_to permit(build(:computacenter_user), object)
    end
  end
end
