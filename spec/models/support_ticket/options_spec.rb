require 'rails_helper'

RSpec.describe SupportTicket::Options do
  describe '#to_a' do
    it 'returns an array of options' do
      options = SupportTicket::Options.new(options: [
        SupportTicket::Option.new('school', 'School'),
        SupportTicket::Option.new('trust', 'Trust'),
      ])

      expect(options.to_a).to be_an(Array)
      expect(options.to_a.first).to be_an(SupportTicket::Option)
    end
  end

  describe '#to_h' do
    it 'returns a hash of options' do
      options = SupportTicket::Options.new(options: [
        SupportTicket::Option.new('school', 'School'),
        SupportTicket::Option.new('trust', 'Trust'),
      ])

      expect(options.to_h).to be_a(Hash)
      expect(options.to_h).to eq({
        school: 'School',
        trust: 'Trust',
      })
    end
  end

  describe '#find_label' do
    it 'returns the label for the given value' do
      options = SupportTicket::Options.new(options: [
        SupportTicket::Option.new('school', 'School'),
        SupportTicket::Option.new('trust', 'Trust'),
      ])

      expect(options.find_label('school')).to eq('School')
    end
  end
end
