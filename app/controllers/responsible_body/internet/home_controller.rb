class ResponsibleBody::Internet::HomeController < ResponsibleBody::Internet::BaseController
  before_action { render_404_unless_responsible_body_in_mno_feature(@responsible_body) }

  def show; end
end
