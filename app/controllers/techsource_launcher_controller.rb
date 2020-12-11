class TechsourceLauncherController < ApplicationController
  def start
    techsource = Computacenter::TechSource.new
    if techsource.unavailable?
      render 'unavailable'
    else
      redirect_to URI.parse(techsource.url).to_s # The URI.parse is needed to appease Brakeman
    end
  end
end
