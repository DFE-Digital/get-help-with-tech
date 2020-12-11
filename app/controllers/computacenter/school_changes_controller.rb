class Computacenter::SchoolChangesController < Computacenter::BaseController
  before_action :set_school, except: :index
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize School
    respond_to do |format|
      format.html do
        @schools = fetch_schools
        @show_download_link = School.with_changes_relevant_to_computacenter.any?
      end
      format.csv { send_data csv_generator, filename: "school-changes-#{Time.zone.now.strftime('%Y%m%d')}.csv" }
    end
  end

  def edit
    authorize @school, :update_computacenter_reference?
    @form = Computacenter::ShipToForm.new(school: @school,
                                          ship_to: @school.computacenter_reference)
  end

  def update
    authorize @school, :update_computacenter_reference?
    @form = Computacenter::ShipToForm.new(ship_to_params.merge(school: @school))

    if @form.valid?
      @school.update_computacenter_reference!(@form.ship_to)
      flash[:success] = t(:success, scope: %i[computacenter ship_to update], name: @school.name, ship_to: @school.computacenter_reference)
      redirect_to computacenter_school_changes_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def set_school
    @school = School.gias_status_open.find_by(urn: params[:id])
    authorize @school, :show?
  end

  def csv_generator
    SchoolDataExporter.new.export_schools(fetch_schools)
  end

  def fetch_schools
    policy_scope(School)
      .joins(:responsible_body)
      .includes(:responsible_body)
      .gias_status_open
      .merge(query_for_view_mode)
      .order(ResponsibleBody.arel_table[:type].asc, ResponsibleBody.arel_table[:name].asc, School.arel_table[:name].asc)
  end

  def view_mode
    @view_mode ||= parse_view_mode
  end

  def parse_view_mode
    if params[:view].in?(%w[new amended])
      params[:view]
    else
      'all'
    end
  end

  def query_for_view_mode
    case view_mode
    when 'new'
      new_schools
    when 'amended'
      amended_schools
    else
      new_schools.or(amended_schools)
    end
  end

  def new_schools
    School.where(computacenter_reference: nil).or(School.computacenter_change_new)
  end

  def amended_schools
    School.computacenter_change_amended
  end

  def ship_to_params
    params.require(:computacenter_ship_to_form).permit(:ship_to, :change_ship_to)
  end
end
