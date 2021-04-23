class ComputacenterReferenceService
  include Computacenter::CapChangeNotifier

  def initialize(school_or_responsible_body)
    @target = school_or_responsible_body
  end

  def update_sold_to!(new_value)
    puts("update_sold_to!")
  end

  def update_ship_to!(new_value)
    puts("update_ship_to!")
    update_reference!(new_value)
  end

private

  def update_reference(new_value)
    @target.update!(computacenter_reference: new_value, computacenter_change: 'none')
  end
end
