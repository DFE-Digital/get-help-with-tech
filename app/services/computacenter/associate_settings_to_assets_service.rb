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
    rb_from_department_sold_to_id(asset.department_sold_to_id) ||
      rb_from_department_id(asset.department_id)
  end

  def rb_from_department_id(department_id)
    ResponsibleBody.find_by_gias_id(department_id[2..]) if department_id&.starts_with?('SC')
  end

  def rb_from_department_sold_to_id(department_sold_to_id)
    ResponsibleBody.find_by_computacenter_reference(department_sold_to_id) if department_sold_to_id.present?
  end

  def school(asset)
    school_from_location_cc_ship_to_account(asset.location_cc_ship_to_account) ||
      school_from_department_id(asset.department_id) ||
      school_from_department(asset.department)
  end

  def school_from_department(name)
    School.find_by_name(name) if name.present?
  end

  def school_from_department_id(department_id)
    return if department_id.blank?

    urn = (department_id[2..]).to_i if department_id&.starts_with?('SC')
    School.where('urn = :urn OR ukprn = :urn OR provision_urn = :p_urn', urn:, p_urn: "SCL#{urn}").first if urn
  end

  def school_from_location_cc_ship_to_account(ship_to)
    School.find_by_computacenter_reference(ship_to) if ship_to.present?
  end

  def school_rb?(school, sold_to)
    return false if [school, sold_to].any?(&:blank?)

    school.responsible_body_computacenter_reference == sold_to
  end

  def set_rb_setting(asset, school)
    if school_rb?(school, asset.department_sold_to_id)
      asset.setting = school.responsible_body
      asset.save!
    else
      rb = rb(asset)
      if rb
        asset.setting = rb
        asset.save!
      end
    end
  end

  def set_school_setting(asset, school)
    return unless school

    unless school.orders_managed_centrally?
      asset.setting = school
      asset.save!
    end
  end
end
