require 'rails_helper'

describe ResponsibleBodyPolicy do
  subject(:policy) { described_class }

  permissions :update_computacenter_reference? do
    it 'blocks access to support users' do
      expect(policy).not_to permit(build(:support_user), :support)
    end

    it 'grants access to Computacenter users' do
      expect(policy).to permit(build(:computacenter_user), :support)
    end
  end
end
