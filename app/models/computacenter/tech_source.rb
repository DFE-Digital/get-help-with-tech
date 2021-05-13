class Computacenter::TechSource
  MAINTENANCE_WINDOW = (Time.zone.parse('29 May 2021 09:00am')..Time.zone.parse('29 May 2021 12:00pm')).freeze

  def url
    Settings.computacenter.techsource_url
  end

  def unavailable?
    MAINTENANCE_WINDOW.cover? Time.zone.now
  end
end
