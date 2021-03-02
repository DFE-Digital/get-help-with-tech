class SupportTicket::AcademyDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::AcademyDetailsForm.new(existing_params)
    render 'support_tickets/academy_details'
  end

  def save
    @form ||= SupportTicket::AcademyDetailsForm.new(academy_details_params)

    if @form.valid?
      support_ticket.update!(
        academy_name: @form.academy_name.titleize,
        school_name: @form.academy_name.titleize,
        school_unique_id: '',
      )

      redirect_to next_step
    else
      render 'support_tickets/academy_details'
    end
  end

private

  def academy_details_params
    params.require(:support_ticket_academy_details_form).permit(:academy_name)
  end

  def existing_params
    {
      academy_name: support_ticket.academy_name,
    }
  end

  def next_step
    support_ticket_contact_details_path
  end
end
