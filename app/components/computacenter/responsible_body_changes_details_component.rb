class Computacenter::ResponsibleBodyChangesDetailsComponent < ViewComponent::Base
  attr_accessor :responsible_body

  def initialize(responsible_body:)
    @responsible_body = responsible_body
  end

  def rows
    array = rb_rows
    array.concat(sold_to_row) if responsible_body.computacenter_reference.present?
    array
  end

private

  def rb_rows
    [{
      key: 'RB URN',
      value: responsible_body.computacenter_identifier,
    },
     {
       key: 'RB Name',
       value: responsible_body.computacenter_name,
     },
     {
       key: 'Address',
       value: responsible_body.address,
     }]
  end

  def sold_to_row
    [{
      key: 'Sold To',
      value: responsible_body.computacenter_reference,
    }]
  end
end
