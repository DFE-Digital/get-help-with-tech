class SupportTicket::DescribeYourselfController < SupportTicket::BaseController
  def new
    @form ||= SupportTicket::DescribeYourselfForm.new(form_params)
    render 'support_tickets/describe_yourself'
  end

  def save
    @form ||= SupportTicket::DescribeYourselfForm.new(describe_yourself_params)

    if @form.valid?
      support_ticket.update!(@form.to_params)
      redirect_to next_step
    else
      render 'support_tickets/describe_yourself'
    end
  end

private

  def describe_yourself_params
    params.require(:support_ticket_describe_yourself_form).permit(:user_type)
  end

  def form_params
    { user_type: support_ticket.user_type }
  end

  def next_step
    case @form.user_type
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
