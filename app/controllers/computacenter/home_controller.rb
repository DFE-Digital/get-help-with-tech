class Computacenter::HomeController < Computacenter::BaseController
  def show
    @schools_requiring_a_new_computacenter_reference_count = School.requiring_a_new_computacenter_reference.size
    @rbs_requiring_a_new_computacenter_reference_count = ResponsibleBody.requiring_a_new_computacenter_reference.size
  end
end
