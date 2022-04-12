require 'rails_helper'

RSpec.describe SupportTicket::OptionsService do
  let(:input) { [{ value: :option_one, label: 'Option one' }] }
  let(:input_with_suggestion_resource_symbol) { [{ value: :option_two, label: 'Option two', suggestions: [{ title: 'Root path', resource: :root }] }] }
  let(:options) { SupportTicket::OptionsService.call(input) }

  describe '#call' do
    it 'returns a SupportTicket::Options' do
      expect(options).to be_a(SupportTicket::Options)
    end

    it 'returns a SupportTicket::Options containing a SupportTicket::Option' do
      expect(options.to_a.first).to be_a(SupportTicket::Option)
    end

    it 'returns a SupportTicket::Options containing the given option' do
      expect(options.to_a.first.value).to eq(:option_one)
      expect(options.to_a.first.label).to eq('Option one')
    end

    context 'when the option has suggestions' do
      let(:input) { input_with_suggestion_resource_symbol }

      it 'returns a SupportTicket::Options containing a SupportTicket::Option with an Array of SupportTicket::Suggestions' do
        expect(options.to_a.first.suggestions).to be_an(Array)
        expect(options.to_a.first.suggestions.first).to be_a(SupportTicket::Suggestion)
      end

      it 'returns a SupportTicket::Options containing a SupportTicket::Option with an Array of SupportTicket::Suggestions containing the given suggestions' do
        expect(options.to_a.first.suggestions.first.title).to eq('Root path')
        expect(options.to_a.first.suggestions.first.resource).to eq(:root)
      end
    end
  end
end
