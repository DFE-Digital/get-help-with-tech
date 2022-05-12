# Service to find out the associated school/rb for computacenter_orders still not associated and link them
class Computacenter::AssociateSettingsToOrdersService < ApplicationService
  def call
    scope_ids = Computacenter::Order.pluck(:id) - Computacenter::Order.joins(:school, :responsible_body).pluck(:id).uniq
    Computacenter::Order.where(id: scope_ids).includes(:raw_order).find_each do |order|
      school = school(order)
      order.update!(ship_to: school&.computacenter_reference, sold_to: rb_sold_to(order, school))
    end
  end

private

  def school(order)
    school_from_ship_to(order.ship_to) ||
      school_from_urn_cc(order.raw_order.urn_cc) ||
      school_from_ship_to_customer(order.raw_order.ship_to_customer) ||
      school_from_responsible_body(order.raw_order.responsible_body)
  end

  def school_from_ship_to(ship_to)
    School.find_by_computacenter_reference(ship_to) if ship_to.present?
  end

  def school_from_ship_to_customer(ship_to_customer)
    School.where("concat(urn, ' ', name) = ?", ship_to_customer).first if ship_to_customer.present?
  end

  def school_from_responsible_body(responsible_body)
    School.find_by_name(responsible_body) if responsible_body.present?
  end

  def school_from_urn_cc(urn_cc)
    return if urn_cc.blank?

    urn = (urn_cc[2..]).to_i if urn_cc&.starts_with?('SC')
    School.where('urn = :urn OR ukprn = :urn OR provision_urn = :p_urn', urn:, p_urn: "SCL#{urn}").first if urn
  end

  def rb_sold_to(order, school)
    return order.sold_to if sold_to.present? && ResponsibleBody.exists?(computacenter_reference: order.sold_to)

    school&.responsible_body_computacenter_reference.presence
  end
end
