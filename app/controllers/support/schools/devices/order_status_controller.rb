class Support::Schools::Devices::OrderStatusController < Support::BaseController
  before_action :set_school, except: %i[collect_urns_to_allow_many_schools_to_order allow_ordering_for_many_schools]
  before_action :set_enable_orders_form, only: %i[update]
  before_action :validate_form, only: %i[update]
  before_action :check_confirmation, only: %i[update]
  before_action :authorize_school_edition, only: %i[collect_urns_to_allow_many_schools_to_order allow_ordering_for_many_schools]

  attr_reader :form, :school

  def edit
    set_enable_orders_form(edition_params)
  end

  def update
    form.save(validate: false) && updated!
  rescue Computacenter::OutgoingAPI::Error => e
    update_error!(e.cap_update_request&.payload_id)
  end

  # GET /support/devices/schools/:urn/enable-orders/confirm
  def confirm
    set_enable_orders_form(confirm_params)
    @laptop_allocation = school.allocation(:laptop)
    @router_allocation = school.allocation(:router)
  end

  def collect_urns_to_allow_many_schools_to_order
    set_bulk_allocation_form
  end

  def allow_ordering_for_many_schools
    set_bulk_allocation_form(**restriction_params)
    form.save ? ordering_allowed_for_many_schools! : error_allowing_ordering_for_many_schools!
  end

private

  def set_bulk_allocation_form(**params)
    @form = Support::BulkAllocationForm.new(**params)
  end

  # Filters
  def authorize_school_edition
    authorize School, :edit?
  end

  def check_confirmation
    unconfirmed! if params[:confirm].blank?
  end

  def set_enable_orders_form(updates = enable_orders_form_params)
    @form = Support::EnableOrdersForm.new(school: school, **updates)
  end

  def set_school
    @school = School.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
    authorize school, :show?
  end

  def validate_form
    orders_cant_be_enabled! unless form.valid?
  end

  # Responses
  def error_allowing_ordering_for_many_schools!
    render :collect_urns_to_allow_many_schools_to_order, status: :unprocessable_entity
  end

  def orders_cant_be_enabled!
    render(:edit, status: :unprocessable_entity)
  end

  def ordering_allowed_for_many_schools!
    redirect_to support_allocation_batch_job_path(form.batch_id)
  end

  def unconfirmed!
    redirect_to support_school_confirm_enable_orders_path(urn: school.urn,
                                                          order_state: form.order_state,
                                                          laptop_cap: form.laptop_cap,
                                                          router_cap: form.router_cap)
  end

  def updated!
    flash[:success] = t(:success, scope: %i[support order_status update])
    redirect_to support_school_path(urn: school.urn)
  end

  def update_error!(payload_id)
    flash[:warning] = t(:cap_update_request_error, scope: %i[support order_status update], payload_id: payload_id)
    render :edit, status: :unprocessable_entity
  end

  # Params
  def confirm_params
    params.permit(:order_state, :laptop_cap, :router_cap).to_h.symbolize_keys
  end

  def edition_params
    {
      order_state: school.order_state,
      laptop_cap: school.cap(:laptop),
      router_cap: school.cap(:router),
    }.merge(enable_orders_form_params)
  end

  def enable_orders_form_params
    params.fetch(:support_enable_orders_form, {})
        .permit(:order_state, :laptop_cap, :router_cap)
        .to_h
        .symbolize_keys
  end

  def restriction_params
    params.require(:support_bulk_allocation_form)
          .permit(:upload, :send_notification)
          .to_h
          .symbolize_keys
  end
end
