class Computacenter::SchoolChangesController < Computacenter::BaseController
  before_action :set_school, except: :index

  def index
    respond_to do |format|
      format.html do
        @schools = fetch_schools
        @show_download_link = show_download_link?
      end
      format.csv { send_data csv_generator, filename: "school-changes-#{Time.zone.now.strftime('%Y%m%d')}.csv" }
    end
  end

  def edit
    @form = Computacenter::ShipToForm.new(school: @school,
                                          ship_to: @school.computacenter_reference)
  end

  def update
    @form = Computacenter::ShipToForm.new(ship_to_params.merge(school: @school))

    if @form.valid?
      update_ship_to
      flash[:success] = t(:success, scope: %i[computacenter ship_to update], name: @school.name)
      redirect_to computacenter_school_changes_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def set_school
    @school = School.gias_status_open.find_by(urn: params[:id])
  end

  def csv_generator
    SchoolDataExporter.new.export_schools(fetch_schools)
  end

  def fetch_schools
    School.joins(:responsible_body)
      .includes(:responsible_body)
      .gias_status_open
      .merge(query_for_view_mode)
      .order(ResponsibleBody.arel_table[:type].asc, ResponsibleBody.arel_table[:name].asc, School.arel_table[:name].asc)
  end

  def view_mode
    @view_mode ||= parse_view_mode
  end

  def parse_view_mode
    mode = params[:view]
    mode = 'all' unless mode.in? %w[new amended]
    mode
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
    params.require(:computacenter_ship_to_form).permit(:ship_to)
  end

  def update_ship_to
    @school.update!(computacenter_reference: @form.ship_to, computacenter_change: 'none')
  end

  def show_download_link?
    School.gias_status_open.where(computacenter_change: %w[new amended]).count.positive?
  end
end
