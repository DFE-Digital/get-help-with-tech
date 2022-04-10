require 'rails_helper'

describe SchoolPolicy do
  subject(:policy) { described_class }

  let(:school) { create(:school) }
  let(:computacenter_user) { build_stubbed(:computacenter_user) }
  let(:support_user) { build_stubbed(:support_user) }
  let(:non_support_user) { build_stubbed(:user, is_support: false) }
  let(:third_line_user) { build_stubbed(:support_user, :third_line) }
  let(:other_rb_user) { build_stubbed(:local_authority_user) }
  let(:rb_user) { build_stubbed(:user, responsible_body: school.rb) }
  let(:school_user) { create(:school_user, school:) }
  let(:other_school_user) { build_stubbed(:school_user) }

  permissions :invite?, :confirm_invitation? do
    xit 'grants access to support users' do
      expect(policy).to permit(support_user, school)
    end

    it 'blocks access to Computacenter users' do
      expect(policy).not_to permit(computacenter_user, school)
    end

    it 'blocks access to support users' do
      expect(policy).not_to permit(support_user, school)
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

    xit 'grants access to support third line users' do
      expect(policy).to permit(third_line_user, school)
    end

    xit 'blocks access to support third line users' do
      expect(policy).not_to permit(third_line_user, school)
    end
  end

  permissions :devices_orderable? do
    it 'blocks access to other rb users' do
      expect(policy).not_to permit(other_rb_user, school)
    end

    it "grants access to school's rb users" do
      expect(policy).to permit(rb_user, school)
    end

    it "blocks access to other school's users" do
      expect(policy).not_to permit(other_school_user, school)
    end

    context 'when the school is centrally managed' do
      let(:school) { build(:school, :centrally_managed) }

      it 'blocks access to school users' do
        expect(policy).not_to permit(school_user, school)
      end
    end

    context 'when the school manages devices' do
      let(:school) { create(:school, :manages_orders) }

      it 'grants access to school users' do
        expect(policy).to permit(school_user, school)
      end
    end
  end
end
