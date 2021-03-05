class Computacenter::TechSource
  NEXT_MAINTENANCE = {
    window_start: Time.zone.local(2021, 3, 6, 9, 0, 0),
    window_end: Time.zone.local(2021, 3, 6, 12, 0, 0),
    maintenance_on_date: Date.new(2021, 2, 6),
    reopened_on_date: Date.new(2021, 3, 6),
  }.freeze

  def next_maintenance
    NEXT_MAINTENANCE
  end

  def url
    Settings.computacenter.techsource_url
  end

  def warn_users_about_upcoming_maintenance_window?
    now = Time.zone.now
    (now >= next_maintenance[:maintenance_on_date].at_beginning_of_day - 2.days) &&
      now <= next_maintenance[:reopened_on_date].at_beginning_of_day
  end

  def unavailable?
    now = Time.zone.now
    now >= next_maintenance[:window_start] && now <= next_maintenance[:window_end]
  end

  def maintenance_message
    formatted_time_start = NEXT_MAINTENANCE[:window_start].strftime('%k:%M%P')
    formatted_time_end = NEXT_MAINTENANCE[:window_end].strftime('%k:%M%P')
    formatted_date = NEXT_MAINTENANCE[:maintenance_on_date].strftime('%A %-d %B')

    "The TechSource website will not be available between #{formatted_time_start} and #{formatted_time_end} on #{formatted_date} due to planned maintenance."
  end
end
