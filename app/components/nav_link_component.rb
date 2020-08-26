class NavLinkComponent < ViewComponent::Base
  attr_reader :title, :url, :html_options

  def initialize(title: nil, url: nil, html_options: {})
    @title = title
    @url = url
    @html_options = html_options
  end
end
