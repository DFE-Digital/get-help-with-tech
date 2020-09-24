class TechsourceLauncherController < ApplicationController
  def start
    if helpers.techsource_unavailable?
      render 'unavailable'
    else
      redirect_to helpers.techsource_url
    end
  end
end
