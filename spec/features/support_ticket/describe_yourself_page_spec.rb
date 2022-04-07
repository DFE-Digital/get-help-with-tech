require 'rails_helper'

RSpec.describe PageObjects::SupportTicket::DescribeYourselfPage do
  let(:describe_yourself_page) { PageObjects::SupportTicket::DescribeYourselfPage.new }

  context 'not signed in' do
    it 'has all the elements on the page' do
      describe_yourself_page.load
      expect(describe_yourself_page).to be_all_there
    end
  end
end
