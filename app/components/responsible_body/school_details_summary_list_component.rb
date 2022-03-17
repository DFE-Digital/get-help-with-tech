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
    array << previously_ordered_devices_row
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
      {
        key: 'Who ordered?',
        value: "The #{who.downcase} ordered devices",
      }
    else
      {
        key: 'Who ordered?',
        value: "#{@school.responsible_body_name} hasn’t decided this yet",
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
      value: @school.raw_allocation(:router).positive? ? 'routers were available to order' : 'no routers were available to order',
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
        key: 'Could place orders?',
        value: 'Yes, a closure or group of self-isolating children was reported',
      }
    elsif @school.can_order_for_specific_circumstances?
      {
        key: 'Could place orders?',
        value: 'Yes, for specific circumstances',
      }
    else
      {
        key: 'Could place orders?',
        value: 'No',
      }
    end
  end

  def previously_ordered_devices_row
    {
      key: 'Previously ordered devices (before September 2021)',
      value: @school.laptops_ordered_in_the_past,
    }
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
    detail_value = @school.chromebook_info_still_needed? ? 'Not known' : t(@school.will_need_chromebooks, scope: %i[activerecord attributes school will_need_chromebooks])
    detail = {
      key: 'Ordered Chromebooks?',
      value: detail_value,
    }

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

      rows += [domain, recovery]
    end
    rows
  end

  def school_contact
    @school.school_contact
  end
end
