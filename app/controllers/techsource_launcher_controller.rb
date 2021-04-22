class TechsourceLauncherController < ApplicationController
  DATE_TIME_FORMAT = Computacenter::TechSourceMaintenanceBannerComponent::DATE_TIME_FORMAT

  def start
    techsource = Computacenter::TechSource.new

    if techsource.unavailable?
      @available_at = Computacenter::TechSource::MAINTENANCE_WINDOW.last.strftime(DATE_TIME_FORMAT)
      render 'unavailable'
    else
      redirect_to URI.parse(techsource.url).to_s # The URI.parse is needed to appease Brakeman
    end
  end
end
