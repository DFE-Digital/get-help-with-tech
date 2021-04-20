class ChromebookInformationForm
  include ActiveModel::Model

  attr_accessor :school, :will_need_chromebooks, :will_need_chromebooks_message
  attr_reader :school_or_rb_domain, :recovery_email_address

  validates :will_need_chromebooks, presence: { message: lambda do |object, _|
                                                            object.will_need_chromebooks_message
                                                           # I18n.t('activemodel.errors.models.chromebook_information_form.custom_errors.will_need_chromebooks', institution_type: object.school&.institution_type || 'school')
                                                         end }

  with_options if: :will_need_chromebooks_and_is_not_a_la_funded_school? do |condition|
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

  def will_need_chromebooks_and_is_not_a_la_funded_school?
    if will_need_chromebooks?
      if school.respond_to?(:la_funded_place?)
        !school.la_funded_place?
      else
        true
      end
    else
      false
    end
  end

  def will_need_chromebooks_message
    @will_need_chromebooks_message ||= default_error_message
  end

  def default_error_message
    I18n.t('activemodel.errors.models.chromebook_information_form.custom_errors.will_need_chromebooks',
           institution_type: school&.institution_type || 'school')
  end
end
