class UsersController < ApplicationController
  before_action { render_404_if_feature_flag_inactive(:public_account_creation) }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      token = SessionService.send_magic_link_email!(@user.email_address)
      redirect_to sent_token_path(token: token)
    else
      render :new
    end
  end

private

  def user_params(opts = params)
    opts.require(:user).permit(
      :full_name,
      :email_address,
      :organisation,
    )
  end
end
