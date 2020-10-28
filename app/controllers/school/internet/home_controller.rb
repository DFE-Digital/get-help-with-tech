class School::Internet::HomeController < School::BaseController
  before_action { render_404_unless_school_in_mno_feature(@school) }

  def show; end
end
