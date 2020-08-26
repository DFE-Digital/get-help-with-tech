class NavComponent < ViewComponent::Base
  def initialize(user:, current_path:)
    @user = user
    @current_path = current_path
  end

  def class_name(url)
    item_class = 'govuk-header__navigation-item'
    item_class += ' govuk-header__navigation-item--active' if @current_path == url
    item_class
  end

  def nav_item(content:, url: nil)
    tag.li(content, class: class_name(url))
  end

  # inline param is for testing
  def render_nav_link(link, context = nil)
    content = context ? link.render_in(context) : render(link)
    nav_item(content: content.strip.html_safe, url: link.url)
  end

  def render_nav_links(links, context = nil)
    links.map { |link|
      render_nav_link(link, context)
    }.join('').html_safe
  end

  def support_links
    [
      NavLinkComponent.new(title: 'Service performance', url: support_service_performance_path),
      NavLinkComponent.new(title: 'Responsible bodies', url: support_responsible_bodies_path),
      NavLinkComponent.new(title: 'Background jobs', url: support_sidekiq_admin_path, html_options: { target: '_blank' }),
    ]
  end

  def computacenter_links
    [
      NavLinkComponent.new(title: 'Home', url: computacenter_home_path),
      NavLinkComponent.new(title: 'API tokens', url: computacenter_api_tokens_path),
    ]
  end

  def mno_links
    [
      NavLinkComponent.new(title: 'Your requests', url: mno_extra_mobile_data_requests_path),
    ]
  end

  def not_signed_in_links
    [
      NavLinkComponent.new(title: 'Guidance', url: guidance_page_path),
      NavLinkComponent.new(title: 'Sign in', url: sign_in_path),
    ]
  end

  def responsible_body_links
    [
      NavLinkComponent.new(title: 'Guidance', url: guidance_page_path),
    ]
  end
end
