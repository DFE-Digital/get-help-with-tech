class Computacenter::TechSourceMaintenanceBannerComponent < ViewComponent::Base
  MAINTENANCE_WINDOW = Computacenter::TechSource::MAINTENANCE_WINDOW
  DATE_TIME_FORMAT = '%A %-d %B %I:%M%P'.freeze

  def message
    "The TechSource website will be closed for maintenance on #{MAINTENANCE_WINDOW.first.strftime(DATE_TIME_FORMAT)}. You can order devices when it reopens on #{MAINTENANCE_WINDOW.last.strftime(DATE_TIME_FORMAT)}."
  end

  def render?
    display_from = 2.days.before(MAINTENANCE_WINDOW.first.beginning_of_day)
    display_until = MAINTENANCE_WINDOW.last
    (display_from..display_until).cover? Time.zone.now
  end
end
