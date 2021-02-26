class SupportTicket::BaseController < ApplicationController
  def start
    render 'support_tickets/start'
  end

  def parent_support
    render 'support_tickets/parent_support'
  end

  def thank_you
    render 'support_tickets/thank_you'
  end

private

  def require_support_ticket_data!
    redirect_to support_ticket_path unless support_ticket.started?
  end

  def support_ticket
    @support_ticket ||= SupportTicket.find_or_create_by!(session_id: session.id.to_s)
  end
end
