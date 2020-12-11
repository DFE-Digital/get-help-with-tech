class Computacenter::TechSource
  def url
    Settings.computacenter.techsource_url
  end

  def unavailable?
    now = Time.zone.now
    window_start = Time.zone.local(2020, 11, 28, 7, 0, 0)
    window_end = Time.zone.local(2020, 11, 28, 23, 0, 0)
    now >= window_start && now <= window_end
  end
end
