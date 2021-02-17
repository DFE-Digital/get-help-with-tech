require 'rails_helper'

RSpec.describe 'school/devices/cannot_order_as_cap_reached.html.erb' do
  let(:school) { user.school }
  let(:user) { build(:school_user) }

  before do
    assign(:school, school)
    assign(:current_user, user)
  end

  it 'does not show allocation uplift warning' do
    render
    expect(rendered).not_to include('Warning')
  end

  context 'school.group_a_feature_flag enabled' do
    before do
      school.update(group_a_feature_flag: true)
    end

    it 'shows allocation uplift warning' do
      render
      expect(rendered).to include('Warning')
    end
  end
end
