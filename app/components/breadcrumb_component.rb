class BreadcrumbComponent < ViewComponent::Base
  validates :items, presence: true

  def initialize(items)
    items = transform_array(items) if items.is_a?(Array) && items.first[:label].nil?
    @items = items
  end

private

  attr_reader :items

  def transform_array(items)
    items.map do |entry|
      if entry.is_a?(Hash)
        { label: entry.keys.first, path: entry.values.first }
      else
        { label: entry }
      end
    end
  end
end
