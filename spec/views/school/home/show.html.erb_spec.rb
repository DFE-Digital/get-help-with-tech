require 'rails_helper'

RSpec.describe 'school/home/show.html.erb' do
  let(:template) { subject.split('.').first }

  let(:school) { user.school }
  let(:user) { build(:school_user) }

  before do
    assign(:school, school)
    assign(:current_user, user)
  end

  it 'always shows the Request internet access section' do
    render template: template, locals: { impersonated_or_current_user: user }
    expect(rendered).to include('Request internet access')
  end
end
