class Computacenter::TechSource
  attr_reader :maintenance_windows

  def initialize(maintenance_windows: [(Time.zone.parse('26 Jun 2021 9:00am')..Time.zone.parse('26 Jun 2021 1:00pm'))])
    @maintenance_windows = maintenance_windows
  end

  def url
    Settings.computacenter.techsource_url
  end

  def available?
    current_maintenance_window.nil?
  end

  def current_maintenance_window
    maintenance_windows.find { |maintenance_window| maintenance_window.cover? current_time }
  end

private

  def current_time
    Time.zone.now
  end
end
