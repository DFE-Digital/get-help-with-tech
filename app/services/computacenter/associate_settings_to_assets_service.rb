# Service to find out the associated school/rb for assets still not associated and link them
class Computacenter::AssociateSettingsToAssetsService < ApplicationService
  def call
    Asset.with_no_setting.find_each do |asset|
      school = school(asset)
      set_school_setting(asset, school) || set_rb_setting(asset, school)
    end
  end

private

  def rb(asset)
    sold_to = asset.department_sold_to_id.presence

    responsible_body = ResponsibleBody.find_by_computacenter_reference(sold_to) if sold_to
    responsible_body ||= ResponsibleBody.find_by_gias_id(asset.department_id[2..]) if asset.department_id&.starts_with?('SC')
    responsible_body
  end

  def school(asset)
    ship_to = asset.location_cc_ship_to_account.presence
    name = asset.department.presence
    school = School.find_by_computacenter_reference(ship_to) if ship_to
    school || (name && School.find_by_name(asset.department))
  end

  def school_rb?(school, sold_to)
    return false if [school, sold_to].any?(&:blank?)

    school.responsible_body_computacenter_reference == sold_to
  end

  def set_rb_setting(asset, school)
    if school_rb?(school, asset.department_sold_to_id)
      asset.setting = school.responsible_body
    else
      rb = rb(asset)
      asset.setting = rb if rb
    end
  end

  def set_school_setting(asset, school)
    return unless school

    asset.setting = school unless school.orders_managed_centrally?
  end
end
