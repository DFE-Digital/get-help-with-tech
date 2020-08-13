class Support::UsersController < Support::BaseController
  def new
    @responsible_body = ResponsibleBody.find(params[:responsible_body_id])
    @user = @responsible_body.users.build
  end

  def create
    @responsible_body = ResponsibleBody.find(params[:responsible_body_id])
    @user = User.new(user_params.merge(responsible_body: @responsible_body, approved_at: Time.zone.now))

    if @user.valid?
      @user.save!
      redirect_to support_responsible_body_path(@responsible_body)
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(
      :full_name,
      :email_address,
    )
  end
end
