class SupportTicket::SchoolDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::SchoolDetailsForm.new(set_params)
    render 'support_tickets/school_details'
  end

  def save
    if form.valid?
      session[:support_ticket].merge!({
        school_name: form.school_name,
        school_urn: form.school_urn,
        school_unique_id: form.school_urn,
      })
      redirect_to next_step
    else
      render 'support_tickets/school_details'
    end
  end

private

  def form
    @form ||= SupportTicket::SchoolDetailsForm.new(school_details_params)
  end

  def school_details_params(opts = params)
    opts.fetch(:support_ticket_school_details_form, {}).permit(:school_name, :school_urn)
  end

  def set_params
    {
      school_name: session[:support_ticket]['school_name'],
      school_urn: session[:support_ticket]['school_urn'],
    }
  end

  def next_step
    support_ticket_contact_details_path
  end
end
