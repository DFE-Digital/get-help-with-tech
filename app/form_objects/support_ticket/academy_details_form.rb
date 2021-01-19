class SupportTicket::AcademyDetailsForm
  include ActiveModel::Model

  attr_accessor :academy_name

  validates :academy_name, presence: { message: 'Enter your academy trust name' }

  def multi_academy_trust_list
    Trust.gias_status_open.multi_academy_trust.order(:name)
  end
end
