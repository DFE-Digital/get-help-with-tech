class SupportTicket::OptionsService < ApplicationService
  def initialize(options = [])
    @options = Array(options).map do |option|
      SupportTicket::Option.new(
        option[:value],
        option[:label],
        suggestions: map_suggestions(option[:suggestions]),
      )
    end
  end

  def call
    SupportTicket::Options.new(options: @options)
  end

private

  def map_suggestions(suggestions)
    Array(suggestions).map do |suggestion|
      SupportTicket::Suggestion.new(
        title: suggestion[:title],
        resource: suggestion[:resource],
      )
    end
  end
end
