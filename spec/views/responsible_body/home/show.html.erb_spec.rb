require 'rails_helper'

RSpec.describe 'responsible_body/home/show.html.erb' do
  describe 'increased_allocations_banner' do
    let(:trust) { create(:trust) }
    let(:school) { create(:school, responsible_body: trust) }

    before do
      school.update! increased_allocations_feature_flag: false
      assign(:responsible_body, trust)
    end

    context 'when increased_allocations_banner feature flag disabled' do
      it 'does not render increased_allocations_banner' do
        render
        expect(rendered).not_to include('We’ve restored original device allocations')
      end
    end

    context 'when increased_allocations_banner feature flag enabled', with_feature_flags: { increased_allocations_banner: 'active' } do
      before do
        school.update increased_allocations_feature_flag: true
      end

      it 'renders increased_allocations_banner' do
        render
        expect(rendered).to include('We’ve restored original device allocations')
      end
    end
  end
end
