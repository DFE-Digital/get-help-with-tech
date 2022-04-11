require 'rails_helper'

RSpec.describe PageObjects::SupportTicket::SchoolDetailsPage do
  let(:app) { PageObjects::SupportTicket::App.new }
  let(:page) { described_class.new }

  context 'not signed in' do
    it 'has all the elements on the page' do
      app.load_school_details_page
      expect(page).to be_all_there
    end

    it 'has the correct heading' do
      app.load_school_details_page
      expect(page.heading.text).to eq('Which school do you work for?')
    end
  end
end
