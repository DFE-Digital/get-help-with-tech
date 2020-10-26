require 'rails_helper'

RSpec.describe 'school/home/show.html.erb' do
  let(:school) { user.school }
  let(:user) { build(:school_user) }

  context 'when school_mno feature is not enabled' do
    it 'does not show Get the internet section' do
      assign(:school, school)
      assign(:user, user)

      render
      expect(rendered).not_to include('Get the internet')
    end
  end

  context 'when school_mno feature is not enabled', with_feature_flags: { school_mno: 'active' } do
    it 'does not show Get the internet section' do
      assign(:school, school)
      assign(:user, user)

      render
      expect(rendered).to include('Get the internet')
    end
  end
end
