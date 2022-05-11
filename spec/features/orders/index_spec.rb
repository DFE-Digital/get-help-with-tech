require 'rails_helper'

RSpec.feature 'List orders' do
  let(:user) { create(:trust_user) }
  let!(:order) { create(:computacenter_order, sold_to: user.responsible_body.computacenter_reference) }

  scenario 'non logged-in users required sign in' do
    visit orders_path

    expect(page).to have_content('Sign in')
  end

  scenario 'logged-in users can see a list of their orders' do
    sign_in_as user
    visit orders_path

    expect(page).to have_content(order.customer_order_number)
  end
end
