class ChromebookInformationForm
  include ActiveModel::Model

  attr_accessor :school, :will_need_chromebooks
  attr_reader :school_or_rb_domain, :recovery_email_address

  validates :will_need_chromebooks, presence: true

  with_options if: :will_need_chromebooks? do |condition|
    condition.validates :recovery_email_address,
                        presence: true,
                        email_address: true

    condition.validates :school_or_rb_domain,
                        presence: true,
                        gsuite_domain: { message: I18n.t('activemodel.errors.models.chromebook_information_form.attributes.school_or_rb_domain.invalid_domain') }
    condition.validate :recovery_email_address_cannot_be_same_domain_as_school_or_rb
  end

  def recovery_email_address=(new_value)
    @recovery_email_address = new_value&.strip
  end

  def school_or_rb_domain=(new_value)
    @school_or_rb_domain = new_value&.strip
  end

  def will_need_chromebooks?
    will_need_chromebooks == 'yes'
  end

  def recovery_email_address_cannot_be_same_domain_as_school_or_rb
    if recovery_email_address&.ends_with?(school_or_rb_domain)
      errors.add(:recovery_email_address, :cannot_be_same_domain_as_school_or_rb)
    end
  end

  def chromebook_domain_label
    label = Array(school.institution_type.capitalize)
    label << "or #{school.responsible_body.humanized_type}" if !school.is_a?(FurtherEducationSchool)
    label << "email domain registered for <span class=‘app-no-wrap’>G Suite for Education</span>"
    label.join(' ').html_safe
  end
end
