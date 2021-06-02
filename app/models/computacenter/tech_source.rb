class Computacenter::TechSource
  MAINTENANCE_WINDOW = (Time.zone.parse('11 Jun 2021 6:00pm')..Time.zone.parse('13 Jun 2021 8:00pm'))

  def url
    Settings.computacenter.techsource_url
  end

  def unavailable?
    MAINTENANCE_WINDOW.cover? Time.zone.now
  end
end
