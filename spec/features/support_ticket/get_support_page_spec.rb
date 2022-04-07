require 'rails_helper'

RSpec.feature 'Get support page' do
  let(:get_support_page) { PageObjects::SupportTicket::GetSupportPage.new }

  context 'not signed in' do
    it 'has all the elements on the page' do
      get_support_page.load
      expect(get_support_page).to be_all_there
    end
  end
end
