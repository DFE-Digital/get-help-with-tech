class TabComponentPreview < ViewComponent::Preview
  def unselected_tab
    render(TabComponent.new(path: '/my/resource/path', label: '3 blind mice', selected: false))
  end

  def selected_tab
    render(TabComponent.new(path: '/my/resource/path', label: '3 blind mice', selected: true))
  end
end
