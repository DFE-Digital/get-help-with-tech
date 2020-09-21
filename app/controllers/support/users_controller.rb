class Support::UsersController < Support::BaseController
  def new
    @responsible_body = ResponsibleBody.find(params[:responsible_body_id])
    @user = @responsible_body.users.build
  end

  def create
    @responsible_body = ResponsibleBody.find(params[:responsible_body_id])
    @user = User.new(user_params.merge(responsible_body: @responsible_body,
                                       approved_at: Time.zone.now,
                                       orders_devices: true))

    if @responsible_body.hybrid_setup?
      @user.school = @responsible_body.schools.first
    end

    if @user.valid?
      if @responsible_body.hybrid_setup?
        @responsible_body.hybrid_setup!
      end
      @user.save!
      redirect_to return_path
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def return_path
    if params[:pilot] == 'devices'
      support_devices_responsible_body_path(@responsible_body)
    else
      support_internet_responsible_body_path(@responsible_body)
    end
  end

  def user_params
    params.require(:user).permit(
      :full_name,
      :email_address,
    )
  end
end
