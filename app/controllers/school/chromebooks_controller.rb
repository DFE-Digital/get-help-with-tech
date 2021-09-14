class School::ChromebooksController < School::BaseController
  def edit
    @chromebook_information_form = ChromebookInformationForm.new(
      school: @school,
      will_need_chromebooks: @school.will_need_chromebooks,
      school_or_rb_domain: @school.school_or_rb_domain,
      recovery_email_address: @school.recovery_email_address,
    )
  end

  def update
    @chromebook_information_form = ChromebookInformationForm.new(
      { school: @school }.merge(chromebook_params),
    )

    authorize @chromebook_information_form, policy_class: School::BasePolicy

    if @chromebook_information_form.valid?
      @school.update_chromebook_information_and_status!(chromebook_params)
      flash[:success] = t(:success, scope: %w[school chromebooks])
      redirect_to after_updated_redirect_location
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def after_updated_redirect_location
    details_school_path(@school)
  end

  def chromebook_params
    params.require(:chromebook_information_form).permit(
      :will_need_chromebooks,
      :school_or_rb_domain,
      :recovery_email_address,
    )
  end
end
