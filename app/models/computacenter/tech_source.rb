class Computacenter::TechSource
  NEXT_MAINTENANCE = {
    window_start: Time.zone.local(2020, 11, 28, 7, 0, 0),
    window_end: Time.zone.local(2020, 11, 28, 23, 0, 0),
    maintenance_on_date: Date.new(2020, 11, 28),
    reopened_on_date: Date.new(2020, 11, 29),
  }.freeze

  def next_maintenance
    NEXT_MAINTENANCE
  end

  def url
    Settings.computacenter.techsource_url
  end

  def warn_users_about_upcoming_maintenance_window?
    Time.zone.now < Time.zone.local(2020, 11, 29, 0, 0, 0)
  end

  def unavailable?
    now = Time.zone.now
    now >= next_maintenance[:window_start] && now <= next_maintenance[:window_end]
  end
end
