class Support::ResponsibleBodiesController < Support::BaseController
  def index
    @responsible_bodies = ResponsibleBody.joins(:users).distinct.order('name asc')
  end
end
