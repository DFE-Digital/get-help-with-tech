class SupportTicket < ApplicationRecord
  attr_accessor :ticket_number

  def requires_school?
    %w[parent_or_guardian_or_carer_or_pupil_or_care_leaver other_type_of_user].exclude? user_type
  end

  def started?
    user_type.present?
  end

  def subject
    if user_type == 'other_type_of_user'
      'ONLINE FORM - Other'
    else
      urn_or_ukprn = "(#{school_unique_id}) " if school_unique_id.present?
      "ONLINE FORM - #{urn_or_ukprn}#{school_name}"
    end
  end

  def submit_to_zendesk
    self.ticket_number = if Settings.zendesk&.username.present? && Settings.zendesk&.token.present?
                           ZendeskService.send!(self)&.id
                         else
                           Kernel.rand(10_000..99_999)
                         end
  end
end
