class Support::ImpersonatesController < Support::BaseController
  before_action { authorize User, policy_class: ImpersonationPolicy }
  before_action :check_self_impersonation, only: [:create]
  before_action :check_support_user_impersonation, only: [:create]
  before_action :check_computacenter_user_impersonation, only: [:create]

  def create
    session[:impersonated_user_id] = params[:impersonated_user_id]

    redirect_to root_url_for(impersonated_user)
  end

  def destroy
    session.delete(:impersonated_user_id)

    redirect_to root_url_for(current_user)
  end

private

  def check_self_impersonation
    if params[:impersonated_user_id] == current_user.id.to_s
      flash[:warning] = 'You cannot impersonate yourself'
      redirect_to(root_url_for(current_user))
    end
  end

  def check_support_user_impersonation
    if User.find(params[:impersonated_user_id]).is_support?
      flash[:warning] = 'You cannot impersonate another support user'
      redirect_to(root_url_for(current_user))
    end
  end

  def check_computacenter_user_impersonation
    if User.find(params[:impersonated_user_id]).is_computacenter?
      flash[:warning] = 'You cannot impersonate a computacenter user'
      redirect_to(root_url_for(current_user))
    end
  end
end
