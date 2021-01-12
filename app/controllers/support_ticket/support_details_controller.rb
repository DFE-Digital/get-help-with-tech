class SupportTicket::SupportDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::SupportDetailsForm.new(set_params)
    render 'support_tickets/support_details'
  end

  def save
    if form.valid?
      session[:support_ticket].merge!({ message: form.message })
      redirect_to next_step
    else
      render 'support_tickets/support_details'
    end
  end

private

  def form
    @form ||= SupportTicket::SupportDetailsForm.new(support_details_params)
  end

  def support_details_params(opts = params)
    opts.fetch(:support_ticket_support_details_form, {}).permit(:message)
  end

  def set_params
    {
      message: session[:support_ticket]['message'],
    }
  end

  def next_step
    support_ticket_check_your_request_path
  end
end
