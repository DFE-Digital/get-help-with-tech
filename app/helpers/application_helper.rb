module ApplicationHelper
  def browser_title
    page_browser_title = content_for(:browser_title).presence || content_for(:title)
    [page_browser_title, t('service_name'), 'GOV.UK'].select(&:present?).join(' - ')
  end

  def yes_no_options
    [
      OpenStruct.new(id: 'yes', name: 'Yes'),
      OpenStruct.new(id: 'no', name: 'No'),
    ]
  end
end
