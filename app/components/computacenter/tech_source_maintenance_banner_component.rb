class Computacenter::TechSourceMaintenanceBannerComponent < ViewComponent::Base
  DATE_TIME_FORMAT = '%A %-d %B %I:%M%P'.freeze

  def initialize(techsource)
    @techsource = techsource
  end

  def message
    maintenance_window = @techsource.current_maintenance_window

    if maintenance_window
      "The TechSource website will be closed for maintenance on <span class=\"app-no-wrap\">#{maintenance_window.first.strftime(DATE_TIME_FORMAT)}.</span> You can order devices when it reopens on <span class=\"app-no-wrap\">#{maintenance_window.last.strftime(DATE_TIME_FORMAT)}.</span>".html_safe
    end
  end

  def render?
    banner_periods = @techsource.maintenance_windows.collect { |maintenance_window| banner_period(maintenance_window) }
    banner_periods.any? { |banner_period| banner_period.cover? current_time }
  end

private

  def banner_period(maintenance_window)
    period_from_start_of_two_days_before_window_to_end_of_window(maintenance_window)
  end

  def period_from_start_of_two_days_before_window_to_end_of_window(maintenance_window)
    display_from = 2.days.before(maintenance_window.first.beginning_of_day)
    display_until = maintenance_window.last
    display_from..display_until
  end

  def current_time
    Time.zone.now
  end
end
