class School::UsersController < School::BaseController
  def index
    @users = @school.users.order(:full_name)
  end
end
