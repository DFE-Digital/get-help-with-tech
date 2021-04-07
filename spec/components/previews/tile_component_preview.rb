class TileComponentPreview < ViewComponent::Preview
  def default
    render(Support::TileComponent.new(count: 123_456, label: 'schools'))
  end

  def other_size
    render(Support::TileComponent.new(count: 123_456, label: 'schools', size: :other))
  end

  def custom_colour
    render(Support::TileComponent.new(count: 123_456, label: 'schools', colour: 'red'))
  end
end
