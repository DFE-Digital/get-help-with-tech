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
    when 'school_contacted'
      :yellow
    when 'ready'
      :green
    else
      raise "You need to define a colour for the #{status} state"
    end
  end

private

  def status
    school.preorder_status_or_default
  end

  attr_reader :school
end
