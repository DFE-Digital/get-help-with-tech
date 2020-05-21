require 'rails_helper'

RSpec.feature 'Submitting an allocation_request_form', type: :feature do
  scenario 'Navigating to the form' do
    visit '/'
    click_on('Tell us how many eligible young people you know about')
    expect(current_path).to eq(new_allocation_request_form_path)
  end

  scenario 'submitting the form with invalid params' do
    visit new_allocation_request_form_path
    fill_in 'Your full name', with: 'Bob'
    fill_in 'Your email address', with: 'no-one@anywhere'
    click_on 'Continue'
    expect(page.status_code).not_to eq(200)
    expect(page).to have_text('error')
  end

  scenario 'submitting the form with valid params' do
    visit new_allocation_request_form_path
    fill_in 'Your full name', with: 'Bob Boberts'
    fill_in 'Your email address', with: 'validmail@localauthority.gov.uk'
    fill_in 'Name of the organisation you work for', with: 'A Local Authority'
    fill_in 'Total number of children and young people eligible for increased internet access', with: 2
    fill_in 'Total number of eligible children and young people who can access a BT hotspot', with: 1
    click_on 'Continue'

    expect(page.status_code).to eq(200)
    expect(page).to have_text('Thank you')
  end
end
