require 'rails_helper'

RSpec.describe 'devices_guidance/how_to_order.html.erb' do
  it 'does not show mass testing banner by default' do
    render
    expect(rendered).not_to include('secondary schools can order laptops')
  end

  it 'show mass testing banner with feature flag', with_feature_flags: { secondary_mass_testing_banner: 'active' } do
    render
    expect(rendered).to include('secondary schools can order laptops')
  end
end
