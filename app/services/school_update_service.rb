class SchoolUpdateService
  def update_schools
    # look at the schools that have changed since the last update
    last_update = DataStage::DataUpdateRecord.last_update_for(:schools)

    # attribute updates for schools
    DataStage::School.updated_since(last_update).find_each(batch_size: 100) do |staged_school|
      update_school(staged_school) if staged_school.counterpart_school.present?
    end

    DataStage::DataUpdateRecord.updated!(:schools)
  end

  def create_school!(staged_school)
    responsible_body_exists!(staged_school.responsible_body_name)

    school = School.create!(staged_school.staged_attributes)
    setup_preorder_information(school)
    setup_allocations(school)

    staged_school.predecessors.each do |predecessor|
      move_remaining_allocations(school, predecessor)
      move_users(school, predecessor)
      predecessor.close!
    end

    add_school_links(staged_school, school)

    school
  end

  def schools_that_need_to_be_added
    DataStage::School.gias_status_open.joins('left join schools s on (staged_schools.urn = s.urn)').where('s.urn is null')
  end

  def schools_that_need_to_be_closed
    DataStage::School.gias_status_closed.joins('left join schools s on (staged_schools.urn = s.urn)').where("s.status='open'")
  end

private

  def add_school_links(staged_school, school)
    staged_school.school_links.each do |link|
      school.school_links.find_or_create_by!(urn: link.link_urn, link_type: link.link_type)

      other_datastage_school = DataStage::School.find_by(urn: link.link_urn)
      other_school = School.find_by(urn: link.link_urn)

      next unless other_datastage_school && other_school

      other_datastage_school.school_links.each do |other_link|
        other_school.school_links.find_or_create_by(urn: other_link.link_urn, link_type: other_link.link_type)
      end
    end
  end

  def find_predecessor(staged_school)
    last_link = staged_school.school_links.any_predecessor.order(created_at: :asc).last
    School.find_by(urn: last_link.link_urn) if last_link
  end

  def setup_preorder_information(school)
    who_will_order = school.responsible_body.who_will_order_devices&.singularize
    school.create_preorder_information!(who_will_order_devices: who_will_order) unless who_will_order.nil?
  end

  def setup_allocations(school)
    school.device_allocations.std_device.create!(allocation: 0)
    school.device_allocations.coms_device.create!(allocation: 0)
  end

  def move_remaining_allocations(school, predecessor)
    rb = predecessor.responsible_body
    unless rb.has_virtual_cap_feature_flags? && rb.has_school_in_virtual_cap_pools?(predecessor)
      predecessor.device_allocations.each do |allocation|
        alloc = allocation.raw_allocation
        ordered = allocation.raw_devices_ordered
        spare_allocation = alloc - ordered

        next unless spare_allocation.positive?

        SchoolDeviceAllocation.transaction do
          school.device_allocations
            .send(allocation.device_type).first
            .update!(allocation: spare_allocation,
                     cap: spare_allocation)

          allocation.update!(allocation: ordered, cap: ordered)
        end
      end
    end
  end

  def move_users(school, predecessor)
    predecessor.users.each { |u| school.users << u }
    predecessor.user_schools.destroy_all
  end

  def responsible_body_exists!(responsible_body_name)
    raise DataStage::Error, "Cannot find responsible body '#{responsible_body_name}'" unless ResponsibleBody.find_by(name: responsible_body_name)
  end

  def update_school(staged_school)
    staged_school.counterpart_school.update!(staged_school.staged_attributes.merge(computacenter_change: 'amended'))
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end
end
