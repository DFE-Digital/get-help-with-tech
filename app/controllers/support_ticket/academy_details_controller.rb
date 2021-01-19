class SupportTicket::AcademyDetailsController < SupportTicket::BaseController
  before_action :require_support_ticket_data!, only: :new

  def new
    @form ||= SupportTicket::AcademyDetailsForm.new(set_params)
    render 'support_tickets/academy_details'
  end

  def save
    if form.valid?
      session[:support_ticket].merge!({
        academy_name: form.academy_name.titleize,
        school_name: form.academy_name.titleize,
        school_unique_id: '',
      })
      redirect_to next_step
    else
      render 'support_tickets/academy_details'
    end
  end

private

  def form
    @form ||= SupportTicket::AcademyDetailsForm.new(academy_details_params)
  end

  def academy_details_params(opts = params)
    opts.fetch(:support_ticket_academy_details_form, {}).permit(:academy_name)
  end

  def set_params
    {
      academy_name: session[:support_ticket]['academy_name'],
    }
  end

  def next_step
    support_ticket_contact_details_path
  end
end
