class ResponsibleBody::Internet::BaseController < ResponsibleBody::BaseController
  before_action :require_connectivity_pilot_participation!

private

  def require_connectivity_pilot_participation!
    render 'errors/forbidden', status: :forbidden unless @responsible_body.in_connectivity_pilot?
  end
end
