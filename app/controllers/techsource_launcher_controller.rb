class TechsourceLauncherController < ApplicationController
  DATE_TIME_FORMAT = Computacenter::TechSourceMaintenanceBannerComponent::DATE_TIME_FORMAT

  def start
    techsource = Computacenter::TechSource.new

    if techsource.available?
      redirect_to URI.parse(techsource.url).to_s # The URI.parse is needed to appease Brakeman
    else
      @available_at = techsource.current_supplier_outage.end_at.strftime(DATE_TIME_FORMAT)
      render 'unavailable'
    end
  end
end
