class SupportTicket::SupportNeedsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::SupportNeedsForm.new(existing_params)
    render 'support_tickets/support_needs'
  end

  def save
    @form ||= SupportTicket::SupportNeedsForm.new(support_needs_params)

    if @form.valid?
      support_ticket.update!(support_topics: remove_empty_topics)
      redirect_to next_step
    else
      render 'support_tickets/support_needs'
    end
  end

private

  def support_needs_params
    params.require(:support_ticket_support_needs_form).permit(support_topics: [])
  end

  def existing_params
    {
      support_topics: support_ticket.support_topics,
    }
  end

  def next_step
    support_ticket_support_details_path
  end

  def remove_empty_topics
    @form.support_topics.reject(&:blank?)
  end
end
