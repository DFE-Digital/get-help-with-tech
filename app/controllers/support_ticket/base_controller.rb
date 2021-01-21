class SupportTicket::BaseController < ApplicationController
  before_action :set_support_ticket

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

  def set_support_ticket
    return unless session[:support_ticket]

    @support_ticket = SupportTicket.new(params: session[:support_ticket])
  end
end
