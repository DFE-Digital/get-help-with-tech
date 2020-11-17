require 'rails_helper'

RSpec.describe 'school/home/show.html.erb' do
  let(:school) { user.school }
  let(:user) { build(:school_user) }

  context 'when school mno_feature_flag is not enabled' do
    it 'does not show Get internet access section' do
      assign(:school, school)
      assign(:current_user, user)

      render
      expect(rendered).not_to include('Get internet access')
    end
  end

  context 'when school mno_feature_flag is enabled' do
    before do
      school.update(mno_feature_flag: true)
    end

    it 'does not show Get internet access section' do
      assign(:school, school)
      assign(:current_user, user)

      render
      expect(rendered).to include('Get internet access')
    end
  end
end
