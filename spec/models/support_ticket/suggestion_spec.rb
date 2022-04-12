require 'rails_helper'

RSpec.describe SupportTicket::Suggestion do
  describe '#initialize' do
    it 'sets the title' do
      suggestion = SupportTicket::Suggestion.new(title: 'Title', resource: 'resource')

      expect(suggestion.title).to eq('Title')
    end

    it 'sets the resource' do
      suggestion = SupportTicket::Suggestion.new(title: 'Title', resource: 'resource')

      expect(suggestion.resource).to eq('resource')
    end
  end
end
