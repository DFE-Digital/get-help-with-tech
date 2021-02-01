require 'rails_helper'

RSpec.describe 'school/home/show.html.erb' do
  let(:school) { user.school }
  let(:user) { build(:school_user) }

  before do
    assign(:school, school)
    assign(:current_user, user)
  end

  it 'always shows the Get internet access section' do
    render
    expect(rendered).to include('Get internet access')
  end

  describe 'increased_allocations_banner' do
    before do
      assign(:school, build(:school, increased_allocations_feature_flag: true))
    end

    context 'when increased_allocations_banner feature flag disabled' do
      it 'does not render increased_allocations_banner' do
        render
        expect(rendered).not_to include('Your allocation has increased to')
      end
    end

    context 'when increased_allocations_banner feature flag enabled', with_feature_flags: { increased_allocations_banner: 'active' } do
      let(:school) { build(:school, :with_std_device_allocation, increased_allocations_feature_flag: true) }

      before do
        school.std_device_allocation.update!(allocation: 10)
        assign(:school, school)
      end

      it 'renders increased_allocations_banner' do
        render
        expect(rendered).to include('Your allocation has increased to 10 devices')
      end
    end
  end
end
