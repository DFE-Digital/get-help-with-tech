class SchoolPreorderStatusTagComponentPreview < ViewComponent::Preview
  STATUS = %w[
    needs_contact
    needs_info
    school_contacted
    school_will_be_contacted
    school_ready
    ready
    rb_can_order
    school_can_order
    ordered
  ].freeze
  WHO_ORDER = %w[responsible_body school].freeze
  VIEWER = [Trust.new, FurtherEducationCollege.new].freeze

  STATUS.each do |status|
    WHO_ORDER.each do |who_order|
      VIEWER.each do |viewer|
        define_method("#{who_order}_orders_#{status}_#{viewer.class.to_s.underscore}_viewing") do
          school = OpenStruct.new(preorder_status_or_default: status, who_will_order_devices: who_order)
          render(SchoolPreorderStatusTagComponent.new(school: school, viewer: viewer))
        end
      end
    end
  end
end
