class Computacenter::SoldToShipToUpdater
  include Computacenter::CapChangeNotifier

  def initialize(school_or_responsible_body)
    @target = school_or_responsible_body
  end

  def update_sold_to!(new_value)
    update_computacenter_reference!(new_value)
    # I don't think we need to do anything special for virtual cap pools here
    @target.schools.each do |school|
      update_caps!(school)
    end
  end

  def update_ship_to!(new_value)
    update_computacenter_reference!(new_value)
    update_caps!(@target)
  end

private

  def update_caps!(school)
    if school.can_notify_computacenter?
      update_cap_on_computacenter!(school.device_allocations.pluck(:id)) 
    end
  end

  def update_computacenter_reference!(new_value)
    @target.update!(computacenter_reference: new_value, computacenter_change: 'none')
  end
end
