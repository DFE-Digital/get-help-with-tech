class TabComponent < ViewComponent::Base
  attr_reader :label, :path, :selected

  def initialize(label:, path:, selected: false)
    @label = label
    @path = path
    @selected = selected
  end

  def tab_classes
    classes = %w[govuk-tabs__list-item]
    classes << 'govuk-tabs__list-item--selected' if @selected
    classes.join(' ')
  end
end
