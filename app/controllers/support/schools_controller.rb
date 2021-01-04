class Support::SchoolsController < Support::BaseController
  before_action { authorize School }

  def search
    @search_form = SchoolSearchForm.new
  end

  def results
    if request.post?
      @search_form = SchoolSearchForm.new(search_params)
      @schools = policy_scope(@search_form.schools).includes(:preorder_information, :responsible_body)
      respond_to do |format|
        format.html {}
        format.csv do
          send_data AllocationsExporter.new.export(@schools), filename: @search_form.csv_filename
        end
      end
    elsif request.get?
      @form = Support::SchoolSuggestionForm.new(name_or_urn: params[:query])
      if @form.valid?
        @schools = @form.matching_schools
        render json: @schools.as_json(only: %i[id name urn postcode town])
      else
        render json: { errors: @form.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def show
    @school = School.find_by!(urn: params[:urn])
    @users = policy_scope(@school.users).not_deleted
    @email_audits = @school.email_audits.order(created_at: :desc)
  end

  def confirm_invitation
    @school = School.find_by!(urn: params[:school_urn])
    @school_contact = @school.preorder_information&.school_contact
    if @school_contact.nil?
      flash[:warning] = I18n.t('support.schools.invite.no_school_contact', name: @school.name)
      redirect_to support_school_path(@school)
    end
  end

  def invite
    school = School.find_by!(urn: params[:school_urn])
    success = school.invite_school_contact
    if success
      flash[:success] = I18n.t('support.schools.invite.success', name: school.name)
    else
      flash[:warning] = I18n.t('support.schools.invite.failure', name: school.name)
    end
    redirect_to support_responsible_body_path(school.responsible_body)
  end

private

  def search_params
    params.require(:school_search_form).permit(:urns, :responsible_body_id, :order_state)
  end
end
