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
    redirect_to support_ticket_path if session[:support_ticket].blank?
  end
end
