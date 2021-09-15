class Support::Schools::Devices::OrderStatusController < Support::BaseController
  before_action :set_school, except: %i[collect_urns_to_allow_many_schools_to_order allow_ordering_for_many_schools]

  def edit
    @form = Support::EnableOrdersForm.new(existing_params.merge(enable_orders_form_params))
  end

  def update
    @form = Support::EnableOrdersForm.new(enable_orders_form_params.merge(school: @school))

    if @form.valid?
      if params[:confirm].present?
        ActiveRecord::Base.transaction do
          service = SchoolOrderStateAndCapUpdateService.new(school: @school,
                                                            order_state: @form.order_state,
                                                            laptop_cap: @form.laptop_cap,
                                                            router_cap: @form.router_cap)
          service.update!
        end
        flash[:success] = t(:success, scope: %i[support order_status update])
        redirect_to support_school_path(urn: @school.urn)
      else
        redirect_to support_school_confirm_enable_orders_path(urn: @school.urn,
                                                              order_state: @form.order_state,
                                                              laptop_cap: @form.laptop_cap,
                                                              router_cap: @form.router_cap)
      end
    else
      render :edit, status: :unprocessable_entity
    end
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

    if @form.valid?
      importer = Importers::AllocationUploadCsv.new(
        path_to_csv: @form.upload.path,
        send_notification: @form.send_notification,
      )
      importer.call
      redirect_to support_allocation_batch_job_path(importer.batch_id)
    else
      render :collect_urns_to_allow_many_schools_to_order, status: :unprocessable_entity
    end
  end

private

  def set_school
    @school = School.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
    authorize @school, :show?
  end

  def existing_params
    {
      order_state: @school.order_state,
      laptop_cap: @school.laptop_cap,
      router_cap: @school.router_cap,
    }
  end

  def enable_orders_form_params(opts = params)
    opts.fetch(:support_enable_orders_form, {}).permit(:order_state, :laptop_cap, :router_cap)
  end

  def restriction_params
    params.require(:support_bulk_allocation_form).permit(:upload, :send_notification)
  end
end
