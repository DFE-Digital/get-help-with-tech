require 'rails_helper'

RSpec.describe 'school/home/show.html.erb' do
  let(:school) { user.school }
  let(:user) { build(:school_user) }

  before do
    assign(:school, school)
    assign(:current_user, user)
  end

  context 'when school mno_feature_flag is not enabled' do
    it 'does not show Get internet access section' do
      render
      expect(rendered).not_to include('Get internet access')
    end
  end

  context 'when school mno_feature_flag is enabled' do
    before do
      school.update(mno_feature_flag: true)
    end

    it 'does not show Get internet access section' do
      render
      expect(rendered).to include('Get internet access')
    end
  end

  describe 'Christmas banner' do
    context 'when christmas_banner feature flag disabled' do
      it 'does not render christmas banner' do
        render
        expect(rendered).not_to include('No orders over Christmas')
      end
    end

    context 'when christmas_banner feature flag enabled', with_feature_flags: { christmas_banner: 'active' } do
      it 'does renders christmas banner' do
        render
        expect(rendered).to include('No orders over Christmas')
      end
    end
  end
end
