class SchoolPreorderStatusTagComponent < ViewComponent::Base
  validates :school, presence: true

  def initialize(school:, viewer: nil)
    @school = school
    @viewer = viewer
  end

  def text
    I18n.t!(status, scope: [:components, :school_preorder_status_tag_component, :status, who_manages_orders_key, text_key])
  end

  def type
    case status
    when 'needs_contact', 'needs_info'
      :grey
    when 'school_contacted', 'school_will_be_contacted'
      :yellow
    when 'school_ready', 'ready'
      :blue
    when 'rb_can_order', 'school_can_order'
      :green
    when 'ordered'
      :purple
    else
      :default
    end
  end

private

  attr_reader :viewer, :school

  def status
    @status ||= school.preorder_status_or_default
  end

  def who_manages_orders_key
    school.orders_managed_by_school? ? :school : :responsible_body
  end

  def text_key
    hash = {
      'trust' => :responsible_body,
      'local_authority' => :responsible_body,
    }

    hash.fetch(viewer.class.to_s.underscore, :default)
  end
end
