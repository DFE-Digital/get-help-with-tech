class TechsourceLauncherController < ApplicationController
  def start
    techsource = Computacenter::TechSource.new
    if helpers.techsource_unavailable?
      render 'unavailable'
    else
      redirect_to techsource.url
    end
  end
end
