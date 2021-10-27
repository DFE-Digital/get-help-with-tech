class School::WelcomeWizardController < School::BaseController
  before_action :set_wizard
  before_action :resume_wizard, except: :next_step

  def next_step
    current_step = params.fetch(:step, @wizard.step)

    authorize @wizard, policy_class: School::WelcomeWizardPolicy

    # clear_user_sign_in_token!
    if @wizard.update_step!(wizard_params, current_step)
      redirect_to next_step_path
    else
      render @wizard.step, status: :unprocessable_entity
    end
  end

  def privacy; end

  def allocation
    @allocation = @school.allocation(:laptop)
  end

  def will_other_order; end

  def devices_you_can_order; end

  def chromebooks; end

  def what_happens_next; end

private

  def set_wizard
    @wizard = impersonated_or_current_user.welcome_wizard_for(@school)
  end

  def resume_wizard
    redirect_to next_step_path unless @wizard.step == action_name
  end

  def wizard_params
    params.require(:school_welcome_wizard).permit(
      :step,
      :user_orders_devices,
      :invite_user,
      :full_name,
      :email_address,
      :telephone,
      :orders_devices,
      :will_need_chromebooks,
      :school_or_rb_domain,
      :recovery_email_address,
    )
  end

  def next_step_path
    return home_school_path if @wizard.complete?

    send("welcome_wizard_#{@wizard.step}_school_path", urn: @wizard.school.urn)
  end

  def clear_user_sign_in_token!
    @wizard.user.clear_token!
  end
end
