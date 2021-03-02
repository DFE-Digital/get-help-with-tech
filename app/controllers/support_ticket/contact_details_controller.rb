class SupportTicket::ContactDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    if current_user.id.present?
      support_ticket.update!(
        full_name: helpers.sanitize(current_user.full_name),
        email_address: helpers.sanitize(current_user.email_address),
        telephone_number: helpers.sanitize(current_user.telephone),
        user_profile_path: support_user_url(current_user.id),
      )

      redirect_to next_step
    else
      @form ||= SupportTicket::ContactDetailsForm.new(existing_params)
      render 'support_tickets/contact_details'
    end
  end

  def save
    @form ||= SupportTicket::ContactDetailsForm.new(contact_details_params)

    if @form.valid?
      support_ticket.update!(full_name: helpers.sanitize(@form.full_name),
                             email_address: helpers.sanitize(@form.email_address),
                             telephone_number: helpers.sanitize(@form.telephone_number),
                             user_profile_path: nil)
      redirect_to next_step
    else
      render 'support_tickets/contact_details'
    end
  end

private

  def contact_details_params
    params.require(:support_ticket_contact_details_form).permit(:full_name, :email_address, :telephone_number)
  end

  def existing_params
    {
      full_name: support_ticket.full_name,
      email_address: support_ticket.email_address,
      telephone_number: support_ticket.telephone_number,
    }
  end

  def next_step
    support_ticket_support_needs_path
  end
end
