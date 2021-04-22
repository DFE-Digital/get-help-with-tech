class School::HomeController < School::BaseController
  def show
    @allocation = @school.std_device_allocation&.allocation || 0
    if @school.la_funded_place?
      render 'show_la_funded_place'
    else
      render
    end
  end
end
