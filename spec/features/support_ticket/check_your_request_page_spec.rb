require 'rails_helper'

RSpec.describe PageObjects::SupportTicket::CheckYourRequestPage do
  let(:app) { PageObjects::SupportTicket::App.new }
  let(:page) { described_class.new }

  context 'not signed in' do
    it 'has all the elements on the page' do
      app.load_check_your_request_page
      expect(page).to be_all_there
    end

    it 'has the correct headings' do
      app.load_check_your_request_page
      expect(page.heading.text).to eq('Check your answers before submitting your request')
      expect(page.which_of_these_best_describes_you).to have_text('Which of these best describes you')
      expect(page.which_school_are_you_in).to have_text('Which school are you in?')
      expect(page.how_can_we_contact_you).to have_text('How can we contact you?')
      expect(page.what_do_you_need_help_with).to have_text('What do you need help with?')
      expect(page.how_can_we_help_you).to have_text('How can we help you?')
    end
  end
end
