module Computacenter
  class TileLinkComponent < Support::TileComponent
    attr_reader :count, :label, :colour, :path

    def initialize(count:, label:, path:, selected: false, colour: :blue, size: :secondary)
      super(count: count, label: label, colour: selected ? :default : colour, size: size)
      @path = path
      @selected = selected
    end

    def link_classes
      classes = %w[app-card__link]
      classes << 'app-card__link--selected' if @selected
      classes
    end
  end
end
