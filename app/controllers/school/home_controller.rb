class School::HomeController < School::BaseController
  def show
    @allocation = @school.std_device_allocation&.allocation || 0
  end
end
