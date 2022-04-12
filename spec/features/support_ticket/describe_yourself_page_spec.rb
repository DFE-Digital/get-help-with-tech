require 'rails_helper'

RSpec.describe PageObjects::SupportTicket::DescribeYourselfPage do
  let(:page) { described_class.new }

  context 'not signed in' do
    it 'has all the elements on the page' do
      page.load
      expect(page).to be_all_there
    end

    it 'has the correct heading' do
      page.load
      expect(page.heading.text).to eq('Which of these best describes you?')
    end
  end
end
