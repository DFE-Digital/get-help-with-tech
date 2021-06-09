class School::Internet::HomeController < School::BaseController
  def show
    @responsible_body = @school.responsible_body
  end
end
