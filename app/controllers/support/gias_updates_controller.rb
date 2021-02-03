class Support::GiasUpdatesController < Support::BaseController
  before_action { authorize :support }

  def index
    @gias_info_form = Support::GiasInfoForm.new
  end
end
