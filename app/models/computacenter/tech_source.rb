class Computacenter::TechSource
  MAINTENANCE_WINDOW = (Time.zone.parse('15 May 2021 8:00am')..Time.zone.parse('15 May 2021 10:00pm')).freeze

  def url
    Settings.computacenter.techsource_url
  end

  def unavailable?
    MAINTENANCE_WINDOW.cover? Time.zone.now
  end
end
