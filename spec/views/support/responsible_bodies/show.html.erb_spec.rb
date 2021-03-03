require 'rails_helper'

RSpec.describe 'support/responsible_bodies/show.html.erb' do
  let(:responsible_body) { create(:trust) }
  let(:schools) { [create(:school, responsible_body: responsible_body)] }
  let(:support_user) { create(:support_user) }

  before do
    enable_pundit(view, support_user)
    assign(:responsible_body, responsible_body)
    assign(:schools, schools)
    assign(:closed_schools, [])
  end

  describe 'banners' do
    context 'when feature flags disabled' do
      before do
        schools.each { |school| school.update!(increased_allocations_feature_flag: false) }
      end

      it 'does not show banners' do
        render
        expect(rendered).not_to include('We’ve restored original device allocations')
      end
    end

    context 'when feature flags enabled', with_feature_flags: { increased_allocations_banner: 'active' } do
      before do
        schools.each { |school| school.update!(increased_allocations_feature_flag: true) }
      end

      it 'shows banners' do
        render
        expect(rendered).to include('We’ve restored original device allocations')
      end
    end
  end
end
