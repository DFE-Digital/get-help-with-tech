require 'rails_helper'

RSpec.describe PageObjects::SupportTicket::CheckYourRequestPage do
  let(:app) { PageObjects::SupportTicket::App.new }
  let(:page) { described_class.new }

  context 'not signed in' do
    it 'has all the elements on the page' do
      app.load_check_your_request_page
      expect(page).to be_all_there
    end

    it 'has the correct heading' do
      app.load_check_your_request_page
      expect(page.heading.text).to eq('Check your answers before submitting your request')
    end
  end
end
