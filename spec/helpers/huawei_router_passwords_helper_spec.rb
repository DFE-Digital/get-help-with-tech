require 'rails_helper'

RSpec.describe HuaweiRouterPasswordsHelper do
  describe '#last_breadcrumb_path_for_huawei' do
    context 'RB' do
      let(:current_user) { create(:local_authority_user) }

      specify { expect(last_breadcrumb_path_for_huawei).to eq(responsible_body_home_path) }
    end

    context 'school' do
      let(:current_user) { create(:school_user) }

      specify { expect(last_breadcrumb_path_for_huawei).to eq(home_school_path(current_user.school)) }
    end

    context 'other type of user' do
      let(:current_user) { create(:mno_user) }

      specify { expect(last_breadcrumb_path_for_huawei).to eq(root_path) }
    end
  end
end
