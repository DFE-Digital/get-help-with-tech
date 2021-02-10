class SupportTicket::ContactDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    if current_user.id.present?
      session[:support_ticket].merge!({
        full_name: helpers.sanitize(current_user.full_name),
        email_address: helpers.sanitize(current_user.email_address),
        telephone_number: helpers.sanitize(current_user.telephone),
        user_profile_path: support_user_url(current_user.id),
      })

      redirect_to next_step
    else
      @form ||= SupportTicket::ContactDetailsForm.new(set_params)
      render 'support_tickets/contact_details'
    end
  end

  def save
    if form.valid?
      session[:support_ticket].merge!({ full_name: helpers.sanitize(form.full_name),
                                        email_address: helpers.sanitize(form.email_address),
                                        telephone_number: helpers.sanitize(form.telephone_number),
                                        user_profile_path: nil })
      redirect_to next_step
    else
      render 'support_tickets/contact_details'
    end
  end

private

  def form
    @form ||= SupportTicket::ContactDetailsForm.new(contact_details_params)
  end

  def contact_details_params(opts = params)
    opts.fetch(:support_ticket_contact_details_form, {}).permit(:full_name, :email_address, :telephone_number)
  end

  def set_params
    {
      full_name: session[:support_ticket]['full_name'],
      email_address: session[:support_ticket]['email_address'],
      telephone_number: session[:support_ticket]['telephone_number'],
    }
  end

  def next_step
    support_ticket_support_needs_path
  end
end
