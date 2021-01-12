class SupportTicket::DescribeYourselfController < SupportTicket::BaseController
  def new
    @form ||= SupportTicket::DescribeYourselfForm.new(set_params)
    render 'support_tickets/describe_yourself'
  end

  def save
    if form.valid?
      session[:support_ticket] = { user_type: form.user_type }
      redirect_to next_step
    else
      render 'support_tickets/describe_yourself'
    end
  end

private

  def form
    @form ||= SupportTicket::DescribeYourselfForm.new(describe_yourself_params)
  end

  def describe_yourself_params(opts = params)
    opts.fetch(:support_ticket_describe_yourself_form, {}).permit(:user_type)
  end

  def set_params
    if session[:support_ticket].present? && session[:support_ticket]['user_type'].present?
      { user_type: session[:support_ticket]['user_type'] }
    end
  end

  def next_step
    case form.user_type
    when 'school_or_single_academy_trust'
      support_ticket_school_details_path
    when 'multi_academy_trust'
      support_ticket_academy_details_path
    when 'local_authority'
      support_ticket_local_authority_details_path
    when 'college'
      support_ticket_college_details_path
    when 'parent_or_guardian_or_carer_or_pupil_or_care_leaver'
      support_ticket_parent_support_path
    when 'other_type_of_user'
      support_ticket_contact_details_path
    end
  end
end
