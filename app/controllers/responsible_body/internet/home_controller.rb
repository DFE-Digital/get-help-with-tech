class ResponsibleBody::Internet::HomeController < ResponsibleBody::Internet::BaseController
  before_action { render_404_unless_responsible_body_has_centrally_managed_schools(@responsible_body) }

  def show; end
end
