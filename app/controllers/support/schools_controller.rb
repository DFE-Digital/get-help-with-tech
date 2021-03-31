class Support::SchoolsController < Support::BaseController
  before_action { authorize School }

  def search
    @search_form = SchoolSearchForm.new
  end

  def results
    if request.post?
      @search_form = SchoolSearchForm.new(search_params)
      if @search_form.valid?
        @schools = policy_scope(@search_form.schools).includes(:preorder_information, :responsible_body)
        respond_to do |format|
          format.html {}
          format.csv do
            send_data AllocationsExporter.new.export(@schools), filename: @search_form.csv_filename
          end
        end
      else
        render :search, status: :unprocessable_entity
      end
    elsif request.get?
      @form = Support::SchoolSuggestionForm.new(name_or_urn_or_ukprn: params[:query])
      if @form.valid?
        @schools = @form.matching_schools
        render json: @schools.as_json(only: %i[id name urn postcode town])
      else
        render json: { errors: @form.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def show
    @school = School.includes(:responsible_body).where_urn_or_ukprn(params[:urn]).first!
    @users = policy_scope(@school.users).not_deleted
    @email_audits = @school.email_audits.order(created_at: :desc)
    @timeline = Timeline::School.new(school: @school)
  end

  def confirm_invitation
    @school = School.where_urn_or_ukprn(params[:school_urn]).first!
    @school_contact = @school.preorder_information&.school_contact
    if @school_contact.nil?
      flash[:warning] = I18n.t('support.schools.invite.no_school_contact', name: @school.name)
      redirect_to support_school_path(@school)
    end
  end

  def invite
    school = School.where_urn_or_ukprn(params[:school_urn]).first!
    success = school.invite_school_contact
    if success
      flash[:success] = I18n.t('support.schools.invite.success', name: school.name)
    else
      flash[:warning] = I18n.t('support.schools.invite.failure', name: school.name)
    end
    redirect_to support_responsible_body_path(school.responsible_body)
  end

  def history
    @school = School.where_urn_or_ukprn(params[:school_urn]).first!
    @history_object = object_for_view_mode
  end

  def edit
    authorize School, :update_name?

    @school = School.where_urn_or_ukprn(params[:urn]).first!
  end

  def update
    authorize School, :update_name?

    @school = School.where_urn_or_ukprn(params[:urn]).first!

    if @school.update(school_params)
      flash[:success] = 'School has been updated'
      redirect_to support_school_path(@school)
    else
      render :edit
    end
  end

private

  def view_mode
    @view_mode ||= parse_view_mode
  end

  def parse_view_mode
    available = %w[school std_device coms_device std_device_pool coms_device_pool caps ordered]
    mode = params[:view]
    mode = 'all' unless mode.in?(available)
    mode
  end

  def object_for_view_mode
    case view_mode
    when 'school'
      @school
    when 'std_device'
      @school&.std_device_allocation
    when 'coms_device'
      @school&.coms_device_allocation
    when 'std_device_pool'
      @school.responsible_body&.std_device_pool
    when 'coms_device_pool'
      @school.responsible_body&.coms_device_pool
    when 'caps'
      @school&.std_device_allocation&.cap_update_calls
    when 'ordered'
      @school.devices_ordered_updates
    else
      @school
    end
  end

  def search_params
    params.require(:school_search_form).permit(
      :search_type,
      :identifiers,
      :responsible_body_id,
      :order_state,
      :name_or_identifier,
      :identifier,
    )
  end

  def school_params
    params.require(:school).permit(:name)
  end
end
