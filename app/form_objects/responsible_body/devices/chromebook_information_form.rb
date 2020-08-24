class ResponsibleBody::Devices::ChromebookInformationForm
  include ActiveModel::Model

  attr_accessor :school, :will_need_chromebooks, :school_or_rb_domain, :recovery_email_address

  validates :will_need_chromebooks, presence: true
  validates :school_or_rb_domain, presence: true, format: /[a-z0-9_\-]+\.[a-z0-9_\-]+.*/, if: :will_need_chromebooks?
  validates :recovery_email_address, presence: true, format: URI::MailTo::EMAIL_REGEXP, if: :will_need_chromebooks?
  validate  :recovery_email_address_cannot_be_same_domain_as_school_or_rb, if: :will_need_chromebooks?

  def will_need_chromebooks?
    will_need_chromebooks == 'yes'
  end

  def recovery_email_address_cannot_be_same_domain_as_school_or_rb
    if recovery_email_address.ends_with?(school_or_rb_domain)
      errors.add(:recovery_email_address, :cannot_be_same_domain_as_school_or_rb)
    end
  end
end
