class School::Internet::HomeController < School::BaseController
  before_action { render_404_if_feature_flag_inactive(:school_mno) }

  def show
  end
end
