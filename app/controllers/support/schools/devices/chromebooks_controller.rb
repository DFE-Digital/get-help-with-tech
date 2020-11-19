class Support::Schools::Devices::ChromebooksController < Support::BaseController
  before_action :set_school
  before_action { authorize PreorderInformation }

  def edit
    @chromebook_information_form = ChromebookInformationForm.new(
      school: @school,
      will_need_chromebooks: @school.preorder_information&.will_need_chromebooks,
      school_or_rb_domain: @school.preorder_information&.school_or_rb_domain,
      recovery_email_address: @school.preorder_information&.recovery_email_address,
    )
  end

  def update
    @preorder_info = @school.preorder_information
    @chromebook_information_form = ChromebookInformationForm.new(
      { school: @school }.merge(chromebook_params),
    )
    if @chromebook_information_form.valid?
      @preorder_info.update_chromebook_information_and_status!(chromebook_params)
      flash[:success] = t(:success, scope: %w[school chromebooks])
      redirect_to support_school_path(@school)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def set_school
    @school = School.find_by_urn(params[:school_urn])
    authorize @school, :show?
  end

  def chromebook_params
    params.require(:chromebook_information_form).permit(
      :will_need_chromebooks,
      :school_or_rb_domain,
      :recovery_email_address,
    )
  end
end
