class Computacenter::TechSource
  MAINTENANCE_WINDOW = (Time.zone.parse('3 Apr 2021 09:00')..Time.zone.parse('3 Apr 2021 12:00')).freeze

  def url
    Settings.computacenter.techsource_url
  end

  def unavailable?
    MAINTENANCE_WINDOW.cover? Time.zone.now
  end
end
