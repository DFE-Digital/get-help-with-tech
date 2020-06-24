class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      token = SessionService.send_magic_link_email!(@user.email_address)
      # NOTE: this is purely to allow us to display the link in the footer
      # REMOVE when we have emails actually being sent
      identifier = @user.sign_in_identifier(token)
      @debug_info = {
        sign_in_token: token,
        sign_in_identifier: identifier,
        sign_in_link: validate_sign_in_token_url(token: token, identifier: identifier),
      }
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
