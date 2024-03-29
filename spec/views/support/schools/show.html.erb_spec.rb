require 'rails_helper'

RSpec.describe 'support/schools/show.html.erb' do
  let(:school) { create(:school, laptops: [1, 0, 0]) }
  let(:support_user) { create(:support_user) }

  before do
    enable_pundit(view, support_user)
    assign(:school, school)
    assign(:current_user, support_user)
    assign(:timeline, Timeline::School.new(school:))
  end

  describe 'when school#can_invite_users? is true' do
    it 'shows Invite a new user button' do
      allow(school).to receive(:can_invite_users?).and_return(true)

      render
      expect(rendered).to include('Invite a new user')
    end
  end

  describe 'when school#can_invite_users? is false' do
    it 'does not show Invite a new user button' do
      allow(school).to receive(:can_invite_users?).and_return(false)

      render
      expect(rendered).not_to include('Invite a new user')
    end
  end

  context 'when there are no related schools' do
    it 'shows tab with zero related schools' do
      render

      expect(rendered).to include('Related schools (0)')
      expect(rendered).to include('There are no related schools')
    end
  end

  context 'when there is a related school' do
    before do
      SchoolLink.create!(school:, urn: '123456', link_type: 'predecessor')
    end

    it 'shows tab with related school' do
      render

      expect(rendered).to include('Related schools (1)')
      expect(rendered).to include('123456')
      expect(rendered).to include('Predecessor')
    end
  end
end
