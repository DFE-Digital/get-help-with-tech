require 'rails_helper'

describe ChromebookPolicy do
  subject(:policy) { described_class }

  permissions :edit?, :update? do
    it 'grants access to support users' do
      expect(policy).to permit(build(:support_user), :any)
    end

    it 'grants access to Computacenter users' do
      expect(policy).to permit(build(:computacenter_user), :any)
    end

    it 'blocks access to school users' do
      expect(policy).not_to permit(build(:school_user), :any)
    end

    it 'blocks access to responsible body users' do
      expect(policy).not_to permit(build(:trust_user), :any)
    end
  end
end
