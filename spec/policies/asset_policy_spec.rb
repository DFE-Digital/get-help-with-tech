require 'rails_helper'

RSpec.describe AssetPolicy, type: :policy do
  let(:school_user) { create(:school_user) }
  let(:rb_user) { create(:local_authority_user) }
  let(:support_user) { create(:support_user) }
  let(:cc_user) { create(:computacenter_user) }

  subject(:policy) { described_class }

  describe 'Scope' do
    specify { expect { Pundit.policy_scope!(nil, Asset) }.to raise_error(/must be logged in/) }
    specify { expect(Pundit.policy_scope!(cc_user, Asset)).to eq(Asset.none) }
    specify { expect(Pundit.policy_scope!(school_user, Asset)).to eq(Asset.all) }
    specify { expect(Pundit.policy_scope!(rb_user, Asset)).to eq(Asset.all) }
    specify { expect(Pundit.policy_scope!(support_user, Asset)).to eq(Asset.all) }
  end

  permissions :show? do
    specify { expect(policy).not_to permit(cc_user, Asset.new) }
    specify { expect(policy).to permit(school_user, Asset.new) }
    specify { expect(policy).to permit(rb_user, Asset.new) }
    specify { expect(policy).to permit(support_user, Asset.new) }
  end

  permissions :create?, :update?, :destroy? do
    specify { expect(policy).not_to permit(cc_user, Asset.new) }
    specify { expect(policy).not_to permit(school_user, Asset.new) }
    specify { expect(policy).not_to permit(rb_user, Asset.new) }
    specify { expect(policy).not_to permit(support_user, Asset.new) }
  end
end
