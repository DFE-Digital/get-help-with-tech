class Support::Users::ResponsibleBodiesController < Support::BaseController
  before_action :set_user
  before_action { authorize User }

  def index
    @form = Support::UserResponsibleBodyForm.new(user: @user, name: user_responsible_body_params[:name])
    @responsible_bodies = @form.matching_responsible_bodies
  end

private

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_responsible_body_params(opts = params)
    opts.fetch('support_user_responsible_body_form').permit(:name)
  end
end
