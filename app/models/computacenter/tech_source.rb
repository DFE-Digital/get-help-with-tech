class Computacenter::TechSource
  MAINTENANCE_WINDOW = (Time.zone.parse('26 Jun 2021 9:00am')..Time.zone.parse('26 Jun 2021 1:00pm'))

  def url
    Settings.computacenter.techsource_url
  end

  def unavailable?
    MAINTENANCE_WINDOW.cover? Time.zone.now
  end
end
