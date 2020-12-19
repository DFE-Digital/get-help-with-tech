class Support::Users::ResponsibleBodyController < Support::BaseController
  before_action :set_user

  def update
    @user.update!(responsible_body_id: responsible_body_params[:responsible_body])
    flash[:success] = success_message
    redirect_to associated_organisations_support_user_path(@user.id)
  end

private

  def responsible_body_params
    params.require(:support_user_responsible_body_form).permit(:responsible_body)
  end

  def success_message
    if @user.responsible_body.present?
      "#{@user.full_name} is now associated with #{@user.responsible_body.name}"
    else
      "#{@user.full_name} is no longer associated with a responsible body"
    end
  end

  def set_user
    @user = User.not_deleted.find(params[:user_id])
    authorize @user, :edit?
  end
end
