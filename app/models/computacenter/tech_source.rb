class Computacenter::TechSource
  MAINTENANCE_WINDOW = (Time.zone.parse('23 Apr 2021 6:00pm')..Time.zone.parse('25 Apr 2021 8:00pm')).freeze

  def url
    Settings.computacenter.techsource_url
  end

  def unavailable?
    MAINTENANCE_WINDOW.cover? Time.zone.now
  end
end
