class SupportTicket::CheckYourRequestController < SupportTicket::BaseController
  def new
    @support_ticket = session[:support_ticket]
    @form = form
    @school_details_path = school_details_path
    render 'support_tickets/check_your_request'
  end

  def save
    if form.valid?
      redirect_to next_step
    else
      render 'support_tickets/check_your_request'
    end
  end

private

  def form
    @form ||= SupportTicket::CheckYourRequestForm.new(ticket: session[:support_ticket])
  end

  def check__params(opts = params)
    opts.fetch(:support_ticket_support_details_form, {})
  end

  def next_step
    support_ticket_thank_you_path
  end

  def school_details_path
    case @support_ticket['user_type']
    when 'school_or_single_academy_trust'
      support_ticket_school_details_path
    when 'multi_academy_trust'
      support_ticket_academy_details_path
    when 'local_authority'
      support_ticket_local_authority_details_path
    when 'college'
      support_ticket_college_details_path
    end
  end
end
