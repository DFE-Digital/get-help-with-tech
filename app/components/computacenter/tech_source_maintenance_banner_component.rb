class Computacenter::TechSourceMaintenanceBannerComponent < ViewComponent::Base
  DATE_TIME_FORMAT = '%A %-d %B %I:%M%P'.freeze

  def initialize(techsource)
    @techsource = techsource
  end

  def message
    supplier_outage = supplier_outage_to_warn_about

    "The TechSource website will be closed for maintenance on <span class=\"app-no-wrap\">#{supplier_outage.start_at.strftime(DATE_TIME_FORMAT)}.</span> You can order devices when it reopens on <span class=\"app-no-wrap\">#{supplier_outage.end_at.strftime(DATE_TIME_FORMAT)}.</span>".html_safe
  end

  def render?
    supplier_outage_to_warn_about.present?
  end

private

  def supplier_outage_to_warn_about
    @techsource.supplier_outages.detect { |supplier_outage| banner_period(supplier_outage).cover? current_time }
  end

  def banner_period(supplier_outage)
    period_from_start_of_two_days_before_supplier_outage_to_end_of_supplier_outage(supplier_outage)
  end

  def period_from_start_of_two_days_before_supplier_outage_to_end_of_supplier_outage(supplier_outage)
    display_from = 2.days.before(supplier_outage.start_at.beginning_of_day)
    display_until = supplier_outage.end_at
    display_from..display_until
  end

  def current_time
    Time.zone.now
  end
end
