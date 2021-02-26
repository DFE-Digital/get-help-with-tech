class SupportTicket::SchoolDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::SchoolDetailsForm.new(existing_params)
    render 'support_tickets/school_details'
  end

  def save
    @form ||= SupportTicket::SchoolDetailsForm.new(school_details_params)

    if @form.valid?
      support_ticket.update!(
        school_name: @form.school_name,
        school_urn: @form.school_urn,
        school_unique_id: @form.school_urn,
      )

      redirect_to next_step
    else
      render 'support_tickets/school_details'
    end
  end

private

  def school_details_params
    params.require(:support_ticket_school_details_form).permit(:school_name, :school_urn)
  end

  def existing_params
    {
      school_name: support_ticket.school_name,
      school_urn: support_ticket.school_urn,
    }
  end

  def next_step
    support_ticket_contact_details_path
  end
end
