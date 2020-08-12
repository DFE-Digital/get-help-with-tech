module ApplicationHelper
  include Pagy::Frontend

  delegate :is_signed_in?, to: :controller

  def browser_title
    service_name = content_for(:devices_service) ? t('page_titles.devices_guidance_index') : t('service_name')
    page_browser_title = content_for(:browser_title).presence || content_for(:title)
    [page_browser_title, service_name, 'GOV.UK'].select(&:present?).join(' - ')
  end

  def yes_no_options
    [
      OpenStruct.new(id: 'yes', name: 'Yes'),
      OpenStruct.new(id: 'no', name: 'No'),
    ]
  end

  def nav_item(title: nil, url: nil, content: nil, html_options: {})
    class_name = 'govuk-header__navigation-item'
    class_name = [class_name, 'govuk-header__navigation-item--active'].join(' ') if request.path == url

    inner_html = (title.present? ? link_to(title, url, { class: 'govuk-header__link' }.merge(html_options)) : content)
    tag.li(inner_html, class: class_name)
  end

  def extra_mobile_data_request_status_class(status)
    {
      requested: 'govuk-tag--blue',
      in_progress: 'govuk-tag--yellow',
      complete: 'govuk-tag--green',
      queried: 'govuk-tag--red',
      cancelled: 'govuk-tag--grey',
      unavailable: 'govuk-tag--grey',
    }[status.to_sym]
  end
end
