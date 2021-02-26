class SupportTicket::LocalAuthorityDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::LocalAuthorityDetailsForm.new(existing_params)
    render 'support_tickets/local_authority_details'
  end

  def save
    @form ||= SupportTicket::LocalAuthorityDetailsForm.new(local_authority_details_params)

    if @form.valid?
      support_ticket.update!(
        local_authority_name: @form.local_authority_name,
        school_name: @form.local_authority_name,
        school_unique_id: '',
      )

      redirect_to next_step
    else
      render 'support_tickets/local_authority_details'
    end
  end

private

  def local_authority_details_params
    params.require(:support_ticket_local_authority_details_form).permit(:local_authority_name)
  end

  def existing_params
    {
      local_authority_name: support_ticket.local_authority_name,
    }
  end

  def next_step
    support_ticket_contact_details_path
  end
end
