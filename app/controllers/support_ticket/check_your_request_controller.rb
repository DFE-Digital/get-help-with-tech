class SupportTicket::CheckYourRequestController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::CheckYourRequestForm.new(support_ticket: support_ticket)
    @school_details_path = school_details_path
    render 'support_tickets/check_your_request'
  end

  def save
    @form ||= SupportTicket::CheckYourRequestForm.new(support_ticket: support_ticket)

    if @form.valid? && support_ticket.submit_to_zendesk
      # TODO: flash message should be enough here???
      session[:support_ticket_number] = support_ticket.ticket_number
      support_ticket.destroy!

      redirect_to next_step
    else
      flash[:warning] = 'There was a problem trying to log your request. Please try again.'
      render 'support_tickets/check_your_request'
    end
  end

private

  def next_step
    support_ticket_thank_you_path
  end

  def school_details_path
    case support_ticket.user_type
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
