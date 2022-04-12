require 'rails_helper'

RSpec.describe SupportTicket::Option do
  describe '#initialize' do
    it 'sets the value' do
      option = SupportTicket::Option.new('school', 'School')

      expect(option.value).to eq(:school)
    end

    it 'sets the label' do
      option = SupportTicket::Option.new('school', 'School')

      expect(option.label).to eq('School')
    end

    it 'sets the suggestions' do
      option = SupportTicket::Option.new('school', 'School', suggestions: [
        SupportTicket::Suggestion.new(title: 'Title', resource: 'Resource'),
      ])
      suggestion = option.suggestions.first

      expect(suggestion.title).to eq('Title')
      expect(suggestion.resource).to eq('Resource')
    end
  end
end
