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

  def nav_item(content:, url: nil, extra_classes: '')
    tag.li(content, class: [class_name(url), extra_classes].join(' ').strip)
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

  def links
    if @user&.is_support?
      support_links
    elsif @user&.is_computacenter?
      computacenter_links + support_links
    elsif @user&.is_mno_user?
      mno_links
    elsif @user&.is_responsible_body_user?
      responsible_body_links
    elsif @user&.is_school_user?
      school_links
    else
      not_signed_in_links
    end
  end

private

  def support_links
    [
      NavLinkComponent.new(title: 'Support home', url: support_home_path),
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
      NavLinkComponent.new(title: 'Sign in', url: sign_in_path),
    ]
  end

  def responsible_body_links
    [
      NavLinkComponent.new(title: 'Home', url: responsible_body_home_path),
      NavLinkComponent.new(title: 'Guidance', url: guidance_page_path),
    ]
  end

  def school_links
    [
      NavLinkComponent.new(title: 'Home', url: schools_path),
      NavLinkComponent.new(title: 'Guidance', url: guidance_page_path),
    ]
  end
end
