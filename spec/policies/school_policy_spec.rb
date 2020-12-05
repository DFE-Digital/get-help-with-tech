require 'rails_helper'

describe SchoolPolicy do
  subject(:policy) { described_class }

  permissions :invite?, :confirm_invitation? do
    it 'grants access to support users' do
      expect(policy).to permit(build(:support_user), :support)
    end

    it 'blocks access to Computacenter users' do
      expect(policy).not_to permit(build(:computacenter_user), :support)
    end
  end

  permissions :search?, :results? do
    it 'grants access to support users' do
      expect(policy).to permit(build(:support_user), :support)
    end

    it 'grants access to Computacenter users' do
      expect(policy).to permit(build(:computacenter_user), :support)
    end
  end

  permissions :update_computacenter_reference? do
    it 'blocks access to support users' do
      expect(policy).not_to permit(build(:support_user), :support)
    end

    it 'grants access to Computacenter users' do
      expect(policy).to permit(build(:computacenter_user), :support)
    end
  end
end
