class School::DetailsController < School::BaseController
  def show
    authorize @school, policy_class: School::DetailsPolicy
  end
end
