module ApplicationHelper
  include Pagy::Frontend

  delegate :is_signed_in?, to: :controller

  def browser_title
    service_name = content_for(:devices_service) ? t('landing_pages.get_support_guides.title') : t('service_name')
    page_browser_title = content_for(:browser_title).presence || content_for(:title)
    [page_browser_title, service_name, 'GOV.UK'].select(&:present?).join(' - ')
  end

  def yes_no_options
    [
      OpenStruct.new(id: 'yes', name: 'Yes'),
      OpenStruct.new(id: 'no', name: 'No'),
    ]
  end

  def api_token_status_colour(status)
    {
      active: 'green',
      expired: 'red',
      revoked: 'red',
    }[status.to_sym]
  end
end
