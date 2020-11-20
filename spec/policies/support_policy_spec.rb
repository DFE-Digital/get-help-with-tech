require 'rails_helper'

describe SupportPolicy do
  subject(:policy) { described_class }

  permissions :new?, :create?, :edit?, :update?, :destroy?, :technical_support? do
    it 'grants access to support users' do
      expect(policy).to permit(build(:support_user), :support)
    end

    it 'blocks access to Computacenter users' do
      expect(policy).not_to permit(build(:computacenter_user), :support)
    end
  end

  permissions :index?, :show?, :schools? do
    it 'grants access to support users' do
      expect(policy).to permit(build(:support_user), :support)
    end

    it 'grants access to Computacenter users' do
      expect(policy).to permit(build(:computacenter_user), :support)
    end
  end
end
