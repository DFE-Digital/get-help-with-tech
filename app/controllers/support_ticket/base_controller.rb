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

  def redirect_if_no_form_data_exists
    return unless request.get?

    redirect_to support_ticket_path if session[:support_ticket].blank?
  end
end
