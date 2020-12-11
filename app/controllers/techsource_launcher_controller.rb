class TechsourceLauncherController < ApplicationController
  def start
    techsource = Computacenter::TechSource.new
    if techsource.unavailable?
      render 'unavailable'
    else
      redirect_to techsource.url
    end
  end
end
