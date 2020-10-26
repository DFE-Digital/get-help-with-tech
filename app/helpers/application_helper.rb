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

  def api_token_status_class(status)
    {
      active: 'govuk-tag--green',
      revoked: 'govuk-tag--grey',
    }[status.to_sym]
  end
end
