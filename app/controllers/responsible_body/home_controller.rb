class ResponsibleBody::HomeController < ResponsibleBody::BaseController
  def show; end

  def privacy_notice; end

  def seen_privacy_notice
    @user.seen_privacy_notice!
    redirect_to responsible_body_home_path
  end
end
