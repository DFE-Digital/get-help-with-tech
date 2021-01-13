class SupportTicket::LocalAuthorityDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::LocalAuthorityDetailsForm.new(set_params)
    render 'support_tickets/local_authority_details'
  end

  def save
    if form.valid?
      session[:support_ticket].merge!({
        local_authority_name: form.local_authority_name,
        school_name: form.local_authority_name,
        school_unique_id: '',
      })
      redirect_to next_step
    else
      render 'support_tickets/local_authority_details'
    end
  end

private

  def form
    @form ||= SupportTicket::LocalAuthorityDetailsForm.new(local_authority_details_params)
  end

  def local_authority_details_params(opts = params)
    opts.fetch(:support_ticket_local_authority_details_form, {}).permit(:local_authority_name)
  end

  def set_params
    {
      local_authority_name: session[:support_ticket]['local_authority_name'],
    }
  end

  def next_step
    support_ticket_contact_details_path
  end
end
