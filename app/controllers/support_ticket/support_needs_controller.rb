class SupportTicket::SupportNeedsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::SupportNeedsForm.new(set_params)
    render 'support_tickets/support_needs'
  end

  def save
    if form.valid?
      session[:support_ticket].merge!({ support_topics: remove_empty_topics })
      redirect_to next_step
    else
      render 'support_tickets/support_needs'
    end
  end

private

  def form
    @form ||= SupportTicket::SupportNeedsForm.new(support_needs_params)
  end

  def support_needs_params(opts = params)
    opts.fetch(:support_ticket_support_needs_form, {}).permit(support_topics: [])
  end

  def set_params
    {
      support_topics: session[:support_ticket]['support_topics'],
    }
  end

  def next_step
    support_ticket_support_details_path
  end

  def remove_empty_topics
    form.support_topics.reject(&:blank?)
  end
end
