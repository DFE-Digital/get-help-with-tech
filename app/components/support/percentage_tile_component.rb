module Support
  class PercentageTileComponent < ViewComponent::Base
    attr_reader :percentage, :label, :colour

    def initialize(percentage:, label:, colour: :default, size: :regular)
      @percentage = percentage
      @label = label
      @colour = colour
      @size = size
    end

    def count_class
      @size == :regular ? 'app-card__count' : 'app-card__secondary-count'
    end
  end
end
