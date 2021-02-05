class Support::Gias::HomeController < Support::BaseController
  before_action { authorize :support }

  def index
    @gias_info_form = Support::GiasInfoForm.new
  end

  def schools_to_add
    @gias_info_form = Support::GiasInfoForm.new
  end

  def schools_to_close
    @gias_info_form = Support::GiasInfoForm.new
  end
end
