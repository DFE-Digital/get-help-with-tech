class Support::SchoolsController < Support::BaseController
  before_action { authorize School }
  before_action :set_form_from_suggestion_params, only: [:results], if: :get_request?
  before_action :set_search_form_from_params, only: [:results], if: :post_request?

  def search
    @search_form = SchoolSearchForm.new
  end

  def results
    if post_request?
      if all_schools? || search_form_valid?
        @schools = all_or_search_form_schools
        respond_to do |format|
          format.html {}
          format.csv do
            send_data AllocationsExporter.new.export(@schools), filename: csv_filename
          end
        end
      else
        render :search, status: :unprocessable_entity
      end
    elsif get_request?
      if @form.valid?
        @schools = @form.matching_schools
        render json: @schools.as_json(only: %i[id name urn postcode town])
      else
        render json: { errors: @form.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def show
    @school = School.includes(:responsible_body).where_urn_or_ukprn_or_provision_urn(params[:urn]).first!
    @users = policy_scope(@school.users)
    @email_audits = @school.email_audits.order(created_at: :desc)
    @timeline = Timeline::School.new(school: @school)
  end

  def confirm_invitation
    @school = School.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
    @school_contact = @school.school_contact
    if @school_contact.nil?
      flash[:warning] = I18n.t('support.schools.invite.no_school_contact', name: @school.name)
      redirect_to support_school_path(@school)
    end
  end

  def invite
    school = School.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
    success = school.invite_school_contact
    if success
      flash[:success] = I18n.t('support.schools.invite.success', name: school.name)
    else
      flash[:warning] = I18n.t('support.schools.invite.failure', name: school.name)
    end
    redirect_to support_responsible_body_path(school.responsible_body)
  end

  def history
    @school = School.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
    @history_object = object_for_view_mode
  end

  def edit
    authorize School, :update_name?

    @school = School.where_urn_or_ukprn_or_provision_urn(params[:urn]).first!
  end

  def update
    authorize School, :update_name?

    @school = School.where_urn_or_ukprn_or_provision_urn(params[:urn]).first!

    if @school.update(school_params)
      flash[:success] = 'School has been updated'
      redirect_to support_school_path(@school)
    else
      render :edit
    end
  end

private

  def all_or_search_form_schools
    school_scope = all_schools? ? School : @search_form.schools
    policy_scope(school_scope).includes(:responsible_body)
  end

  def all_schools?
    @all_schools ||= params[:all_schools].to_s.casecmp('true').zero?
  end

  def all_schools_params
    params.permit(:all_schools)
  end

  def csv_filename
    return @search_form.csv_filename if @search_form.present?

    "#{Time.zone.now.iso8601}_all_school_allocations_export.csv"
  end

  def get_request?
    request.get?
  end

  def view_mode
    @view_mode ||= parse_view_mode
  end

  def parse_view_mode
    available = %w[school std_device coms_device caps ordered]
    mode = params[:view]
    mode = 'all' unless mode.in?(available)
    mode
  end

  def object_for_view_mode
    case view_mode
    when 'responsible_body'
      @school.responsible_body
    when 'caps'
      @school&.cap_update_calls
    when 'ordered'
      @school.devices_ordered_updates
    else
      @school
    end
  end

  def post_request?
    request.post?
  end

  def search_form_valid?
    @search_form && @search_form.valid?
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

  def set_form_from_suggestion_params
    @form = Support::SchoolSuggestionForm.new(name_or_urn_or_ukprn: params[:query])
  end

  def set_search_form_from_params
    @search_form = all_schools? ? nil : SchoolSearchForm.new(search_params)
  end

  def school_params
    params.require(:school).permit(:name)
  end
end
