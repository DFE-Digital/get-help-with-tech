class SupportTicket::SupportDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::SupportDetailsForm.new(existing_params)
    render 'support_tickets/support_details'
  end

  def save
    @form ||= SupportTicket::SupportDetailsForm.new(support_details_params)

    if @form.valid?
      support_ticket.update!(message: @form.message)
      redirect_to next_step
    else
      render 'support_tickets/support_details'
    end
  end

private

  def support_details_params
    params.require(:support_ticket_support_details_form).permit(:message)
  end

  def existing_params
    {
      message: support_ticket.message,
    }
  end

  def next_step
    support_ticket_check_your_request_path
  end
end
