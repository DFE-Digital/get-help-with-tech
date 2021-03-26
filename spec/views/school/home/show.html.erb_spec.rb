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
    expect(rendered).to include('Internet access')
  end
end
