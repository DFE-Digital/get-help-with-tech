class SchoolPreorderStatusTagComponent < ViewComponent::Base
  validates :school, presence: true

  def initialize(school:)
    @school = school
  end

  def text
    I18n.t!(status, scope: PreorderInformation.enum_i18n_scope(:status))
  end

  def type
    case status
    when 'needs_contact', 'needs_info'
      :grey
    when 'school_contacted', 'school_will_be_contacted'
      :yellow
    when 'school_ready', 'ready'
      :blue
    else
      :default
    end
  end

private

  def status
    school.preorder_status_or_default
  end

  attr_reader :school
end
