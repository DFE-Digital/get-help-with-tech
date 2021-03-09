class ResponsibleBody::Internet::HomeController < ResponsibleBody::Internet::BaseController
  before_action { render_404_unless_responsible_body_has_connectivity_feature_flags(@responsible_body) }

  def show; end
end
