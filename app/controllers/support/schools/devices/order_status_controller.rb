class Support::Schools::Devices::OrderStatusController < Support::BaseController
  before_action :set_school, except: %i[collect_urns_to_allow_many_schools_to_order allow_ordering_for_many_schools]
  before_action :set_form, only: %i[update]
  before_action :validate_form, only: %i[update]
  before_action :check_confirmation, only: %i[update]

  attr_reader :form

  def edit
    @form = Support::EnableOrdersForm.new(existing_params.merge(enable_orders_form_params))
  end

  def update
    form.save(validate: false)
    flash[:success] = t(:success, scope: %i[support order_status update])
    redirect_to support_school_path(urn: school.urn)
  rescue Computacenter::OutgoingAPI::Error => e
    flash[:warning] = t(:cap_update_request_error, scope: %i[support order_status update], payload_id: e.cap_update_request&.payload_id)
    render :edit, status: :unprocessable_entity
  end

  # GET /support/devices/schools/:urn/enable-orders/confirm
  def confirm
    @form = Support::EnableOrdersForm.new(order_state: params[:order_state],
                                          laptop_cap: params[:laptop_cap],
                                          router_cap: params[:router_cap])
    @laptop_allocation = @school.laptop_allocation
    @router_allocation = @school.router_allocation
  end

  def collect_urns_to_allow_many_schools_to_order
    authorize School, :edit?
    @form = Support::BulkAllocationForm.new
  end

  def allow_ordering_for_many_schools
    authorize School, :edit?
    @form = Support::BulkAllocationForm.new(restriction_params)

    if form.save
      redirect_to support_allocation_batch_job_path(form.batch_id)
    else
      render :collect_urns_to_allow_many_schools_to_order, status: :unprocessable_entity
    end
  end

private

  # Filters
  def check_confirmation
    unconfirmed! if params[:confirm].blank?
  end

  def set_form
    @form = Support::EnableOrdersForm.new(enable_orders_form_params.merge(school: school))
  end

  def set_school
    @school = School.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
    authorize @school, :show?
  end

  def validate_form
    invalid_form! unless form.valid?
  end

  # Responses
  def invalid_form!
    render(:edit, status: :unprocessable_entity)
  end

  def unconfirmed!
    redirect_to support_school_confirm_enable_orders_path(urn: school.urn,
                                                          order_state: form.order_state,
                                                          laptop_cap: form.laptop_cap,
                                                          router_cap: form.router_cap)
  end

  # Params
  def enable_orders_form_params(opts = params)
    opts.fetch(:support_enable_orders_form, {}).permit(:order_state, :laptop_cap, :router_cap)
  end

  def existing_params
    {
      order_state: @school.order_state,
      laptop_cap: @school.laptop_cap,
      router_cap: @school.router_cap,
    }
  end

  def restriction_params
    params.require(:support_bulk_allocation_form).permit(:upload, :send_notification)
  end
end
