class Computacenter::ResponsibleBodyChangesController < Computacenter::BaseController
  before_action :set_responsible_body, except: :index
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize ResponsibleBody
    respond_to do |format|
      format.html do
        @responsible_bodies = fetch_responsible_bodies
        @show_download_link = ResponsibleBody.with_changes_relevant_to_computacenter.any?
      end
      format.csv { send_data csv_generator, filename: "rb-changes-#{Time.zone.now.strftime('%Y%m%d')}.csv" }
    end
  end

  def edit
    authorize @responsible_body, :update_computacenter_reference?
    @form = Computacenter::SoldToForm.new(responsible_body: @responsible_body,
                                          sold_to: @responsible_body.computacenter_reference)
  end

  def update
    authorize @responsible_body, :update_computacenter_reference?
    @form = Computacenter::SoldToForm.new(sold_to_params.merge(responsible_body: @responsible_body))

    if @form.valid?
      update_sold_to
      flash[:success] = t(:success, scope: %i[computacenter sold_to update], name: @responsible_body.name,
                                    sold_to: @responsible_body.computacenter_reference)
      redirect_to computacenter_responsible_body_changes_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def set_responsible_body
    @responsible_body = ResponsibleBody.gias_status_open.find(params[:id])
    authorize @responsible_body, :show?
  end

  def csv_generator
    ResponsibleBodyExporter.new.export_responsible_bodies(fetch_responsible_bodies)
  end

  def fetch_responsible_bodies
    policy_scope(ResponsibleBody)
      .gias_status_open
      .merge(query_for_view_mode)
      .order(ResponsibleBody.arel_table[:type].asc, ResponsibleBody.arel_table[:name].asc)
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
      new_responsible_bodies
    when 'amended'
      amended_responsible_bodies
    when 'all'
      new_responsible_bodies.or(amended_responsible_bodies)
    end
  end

  def new_responsible_bodies
    ResponsibleBody.where(computacenter_reference: nil).or(ResponsibleBody.computacenter_change_new)
  end

  def amended_responsible_bodies
    ResponsibleBody.computacenter_change_amended
  end

  def sold_to_params
    params.require(:computacenter_sold_to_form).permit(:sold_to, :change_sold_to)
  end

  def update_sold_to
    @responsible_body.update!(computacenter_reference: @form.sold_to, computacenter_change: 'none')
  end
end
