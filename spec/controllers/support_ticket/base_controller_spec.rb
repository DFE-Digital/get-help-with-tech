require 'rails_helper'

RSpec.describe SupportTicket::BaseController, type: :controller do
  describe '#start' do
    it 'responds successfully' do
      get :start
      expect(response).to be_successful
    end
  end

  describe '#parent_support' do
    it 'responds successfully' do
      get :parent_support
      expect(response).to be_successful
    end
  end

  describe '#thank_you' do
    it 'responds successfully' do
      get :thank_you
      expect(response).to be_successful
    end
  end
end
