class ResponsibleBody::Internet::Mobile::ManualRequestsController < ResponsibleBody::BaseController
  def index
    @extra_mobile_data_requests = @current_user.extra_mobile_data_requests
  end

  def new
    # If the user clicks 'Change' on the confirmation page, we don't want to
    # pass all the params back on the URL, so we retrieve them from the session
    # if they're present
    @extra_mobile_data_request = presenter(ExtraMobileDataRequest.new(session[:extra_mobile_data_request_params] || {}))
    get_participating_mobile_networks
  end

  def create
    @extra_mobile_data_request = ExtraMobileDataRequest.new(
      extra_mobile_data_request_params.merge(created_by_user: @current_user,
                                             responsible_body: @current_user.responsible_body),
    )

    if @extra_mobile_data_request.valid?
      if params[:confirm]
        # clear the stashed params once the user has confirmed them
        session.delete(:extra_mobile_data_request_params)

        @extra_mobile_data_request.save_and_notify_account_holder!

        flash[:success] = build_success_message(@extra_mobile_data_request.mobile_network.participating?)
        redirect_to responsible_body_internet_mobile_extra_data_requests_path
      else
        # store given params in session,so that we don't have to pass them back in the URL
        # if the user clicks 'Change' on the confirmation page
        session[:extra_mobile_data_request_params] = extra_mobile_data_request_params
        @extra_mobile_data_request = presenter(@extra_mobile_data_request)
        render :confirm
      end
    else
      # remove any error message on mobile_network to stop it rendering a poorly-worded
      # default message in the error_summary that doesn't link to the right field
      # - it's ok, we have a better message in the validation on mobile_network_id
      @extra_mobile_data_request.errors.delete(:mobile_network)
      @extra_mobile_data_request = presenter(@extra_mobile_data_request)
      get_participating_mobile_networks
      render :new, status: :unprocessable_entity
    end
  end

private

  def get_participating_mobile_networks
    @participating_mobile_networks = MobileNetwork.participating_in_pilot.order('LOWER(brand)')
  end

  def extra_mobile_data_request_params
    params.require(:extra_mobile_data_request).permit(%i[
      account_holder_name
      agrees_with_privacy_statement
      device_phone_number
      mobile_network_id
      contract_type
      confirm
    ])
  end

  def build_success_message(mno_is_participating)
    if mno_is_participating
      I18n.t('responsible_body.extra_mobile_data_requests.create.success.participating_mno')
    else
      I18n.t('responsible_body.extra_mobile_data_requests.create.success.non_participating_mno')
    end
  end

  def presenter(extra_mobile_data_request)
    ExtraMobileDataRequestPresenter.new(extra_mobile_data_request)
  end
end
