require 'rails_helper'

describe SchoolPolicy do
  subject(:policy) { described_class }

  let(:school) { build(:school) }
  let(:computacenter_user) { build_stubbed(:computacenter_user) }
  let(:support_user) { build_stubbed(:support_user) }
  let(:non_support_user) { build_stubbed(:user, is_support: false) }
  let(:third_line_user) { build_stubbed(:support_user, :third_line) }

  permissions :invite?, :confirm_invitation? do
    it 'grants access to support users' do
      expect(policy).to permit(support_user, school)
    end

    it 'blocks access to Computacenter users' do
      expect(policy).not_to permit(computacenter_user, school)
    end
  end

  permissions :search?, :results? do
    it 'grants access to support users' do
      expect(policy).to permit(support_user, school)
    end

    it 'grants access to Computacenter users' do
      expect(policy).to permit(computacenter_user, school)
    end
  end

  permissions :update_computacenter_reference? do
    it 'blocks access to support users' do
      expect(policy).not_to permit(support_user, school)
    end

    it 'grants access to Computacenter users' do
      expect(policy).to permit(computacenter_user, school)
    end
  end

  permissions(*%i[update_address? update_headteacher? update_name? update_responsible_body?]) do
    it 'block access to non support users' do
      expect(policy).not_to permit(non_support_user, school)
    end

    it 'block access to non support third line users' do
      expect(policy).not_to permit(support_user, school)
    end

    it 'grants access to support third line users' do
      expect(policy).to permit(third_line_user, school)
    end
  end
end
