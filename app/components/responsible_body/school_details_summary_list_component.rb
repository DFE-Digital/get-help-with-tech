class ResponsibleBody::SchoolDetailsSummaryListComponent < ViewComponent::Base
  include ViewHelper
  validates :school, presence: true

  delegate :orders_managed_by_school?, to: :@school

  def initialize(school:, viewer: nil)
    @school = school
    @viewer = viewer
  end

  def rows
    array = []
    array << preorder_status_row
    array << who_will_order_row
    array << device_allocation_row
    array << devices_ordered_row if display_devices_ordered_row?
    array << router_allocation_row if display_router_allocation_row?
    array << routers_ordered_row if display_routers_ordered_row?
    array << order_status_row
    array << school_type_row

    array +
      school_contact_row_if_contact_present +
      chromebook_rows_if_needed
  end

private

  attr_reader :viewer

  def preorder_status_row
    {
      key: 'Status',
      value: render(SchoolPreorderStatusTagComponent.new(school: @school, viewer: viewer)),
    }
  end

  def who_will_order_row
    who = @school.who_manages_orders_label

    if who.present?
      detail = {
        key: 'Who will order?',
        value: "The #{who.downcase} orders devices",
        action: 'who will order',
      }

      if @school.can_change_who_manages_orders?
        detail.merge!(
          change_path: responsible_body_devices_school_change_who_will_order_path(school_urn: @school.urn),
        )
      end
      detail
    else
      {
        key: 'Who will order?',
        value: "#{@school.responsible_body_name} hasn’t decided this yet",
        action_path: responsible_body_devices_who_will_order_edit_path,
        action: 'Decide who will order',
      }
    end
  end

  def device_allocation_row
    {
      key: 'Device allocation',
      value: pluralize(@school.raw_allocation(:laptop), 'device'),
    }
  end

  def router_allocation_row
    {
      key: 'Router allocation',
      value: @school.raw_allocation(:router).positive? ? 'routers are available to order' : 'no routers are available to order',
    }
  end

  def devices_ordered_row
    {
      key: 'Devices ordered',
      value: pluralize(@school.devices_ordered(:laptop), 'device'),
    }
  end

  def routers_ordered_row
    {
      key: 'Routers ordered',
      value: pluralize(@school.devices_ordered(:router), 'router'),
    }
  end

  def display_devices_ordered_row?
    !@school.vcap? && @school.has_ordered_any_laptop?
  end

  def display_routers_ordered_row?
    !@school.vcap? && @school.has_ordered_any_router?
  end

  def display_router_allocation_row?
    false
  end

  def order_status_row
    if @school.can_order?
      {
        key: 'Can place orders?',
        value: 'Yes, a closure or group of self-isolating children has been reported',
      }
    elsif @school.can_order_for_specific_circumstances?
      {
        key: 'Can place orders?',
        value: 'Yes, for specific circumstances',
      }
    else
      {
        key: 'Can place orders?',
        value: 'Cannot order yet',
      }
    end
  end

  def school_type_row
    {
      key: 'Setting',
      value: @school.human_for_school_type,
    }
  end

  def school_contact_row_if_contact_present
    orders_managed_by_school? && school_contact.present? ? [school_contact_row] : []
  end

  def school_contact_row
    {
      key: 'School contact',
      value: contact_lines.map { |line| h(line) }.join('<br>').html_safe,
      change_path: responsible_body_devices_school_who_to_contact_edit_path(school_urn: @school.urn),
      action: 'Change',
    }
  end

  def contact_lines
    [
      [school_contact.title.presence&.upcase_first, school_contact.full_name].compact.join(': '),
      school_contact.email_address,
      school_contact.phone_number,
    ].reject(&:blank?)
  end

  def chromebook_rows_if_needed
    detail_value = @school.chromebook_info_still_needed? ? 'Not yet known' : t(@school.will_need_chromebooks, scope: %i[activerecord attributes school will_need_chromebooks])
    detail = {
      key: 'Ordering Chromebooks?',
      value: detail_value,
    }

    if @school.orders_managed_centrally?
      change_path = responsible_body_devices_school_chromebooks_edit_path(school_urn: @school.urn)
      detail.merge!({
        change_path: change_path,
        action: 'whether Chromebooks are needed',
      })
    end

    rows = [detail]

    if @school.will_need_chromebooks?
      domain = {
        key: 'Domain',
        value: @school.school_or_rb_domain,
      }
      recovery = {
        key: 'Recovery email',
        value: @school.recovery_email_address,
      }

      if @school.orders_managed_centrally?
        domain.merge!({
          change_path: change_path,
          action: 'domain',
        })
        recovery.merge!({
          change_path: change_path,
          action: 'recovery email',
        })
      end
      rows += [domain, recovery]
    end
    rows
  end

  def school_contact
    @school.school_contact
  end
end
