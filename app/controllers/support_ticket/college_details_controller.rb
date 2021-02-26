class SupportTicket::CollegeDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::CollegeDetailsForm.new(existing_params)
    render 'support_tickets/college_details'
  end

  def save
    @form ||= SupportTicket::CollegeDetailsForm.new(college_details_params)

    if @form.valid?
      support_ticket.update!(
        college_name: @form.college_name,
        college_ukprn: @form.college_ukprn,
        school_name: @form.college_name,
        school_unique_id: @form.college_ukprn,
      )

      redirect_to next_step
    else
      render 'support_tickets/college_details'
    end
  end

private

  def college_details_params
    params.require(:support_ticket_college_details_form).permit(:college_name, :college_ukprn)
  end

  def existing_params
    {
      college_name: support_ticket.college_name,
      college_ukprn: support_ticket.college_ukprn,
    }
  end

  def next_step
    support_ticket_contact_details_path
  end
end
