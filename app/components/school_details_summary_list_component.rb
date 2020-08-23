class SchoolDetailsSummaryListComponent < ViewComponent::Base
  validates :school, presence: true

  def initialize(school:)
    @school = school
  end

  def rows
    [
      {
        key: 'Status',
        value: render(SchoolPreorderStatusTagComponent.new(school: @school)),
      },
      {
        key: 'Provisional allocation',
        value: pluralize(@school.std_device_allocation&.allocation.to_i, 'device'),
      },
      {
        key: 'Type of school',
        value: @school.type_label,
      },
      {
        key: 'Who will order?',
        value: "The #{(@school.preorder_information || @school.responsible_body).who_will_order_devices_label.downcase} orders devices",
      },
    ]
  end
end
