class School::WelcomeWizardController < School::BaseController
  def next_step; end

  def welcome; end

private

  def user_params
    params.require(:user).permit(
      :full_name,
      :email_address,
      :telephone,
      :orders_devices,
    )
  end
end
